#! /usr/bin/env bash

set -eo pipefail

function info { echo "[INFO] $1"; }
function error { echo "[ERROR] $1" 1>&2; exit 1; }

#####
## This script sets up Django before starting the WSGI server
##
## The first time this script is executed, it is run as root. It then updates the
## trust store and runs the customisations as root before re-running itself as
## the Django user.
##
## The second run as the Django user then applies migrations, creates the superuser
## if required, collects the static files and starts gunicorn.
#####

# Configure settings module to the first argument
info "Using DJANGO_SETTINGS_MODULE = $1"
export DJANGO_SETTINGS_MODULE="$1"

# If we are running as root, update the certificates and run the customisations
if [ "$(id -u)" = "0" ]; then
    # Make sure the trusted certificates have been updated
    info "Updating trusted certificates"
    update-ca-certificates > /dev/null
    # Make sure Python uses the correct trust bundle
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

    # Execute customisations from /django-init.d before doing anything
    info "Running customisations"
    if [ -d "/django-init.d" ]; then
        for file in $(find /django-init.d/ -mindepth 1 -type f -executable | sort -n); do
            case "$file" in
                *.sh) . $file ;;
                *) eval $file ;;
            esac
        done
    fi

    # Run this script again as the Django user
    exec gosu "$DJANGO_USER" "$BASH_SOURCE" "$@"
fi

# Run database migrations
info "Running database migrations"
django-admin migrate --no-input > /dev/null

# Create Django superuser if required
if [ "${DJANGO_CREATE_SUPERUSER:-0}" -eq 1 ]; then
    # We require that username and email exist
    [ -z "$DJANGO_SUPERUSER_USERNAME" ] && \
        error "DJANGO_SUPERUSER_USERNAME must be set to create superuser"
    [ -z "$DJANGO_SUPERUSER_EMAIL" ] && \
        error "DJANGO_SUPERUSER_EMAIL must be set to create superuser"
    # When passed to the Django shell, this command exits with a non-zero exit
    # code if the user already exists
    superuser_exists_command="
import sys
from django.contrib.auth import get_user_model

if get_user_model().objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    sys.exit(1)
"
    # A zero exit status means the user needs to be created
    if django-admin shell <<< "$superuser_exists_command" > /dev/null; then
        info "Creating Django superuser"
        # Create the superuser with an unusable password
        django-admin createsuperuser --no-input  \
                                     --username "$DJANGO_SUPERUSER_USERNAME"  \
                                     --email "$DJANGO_SUPERUSER_EMAIL"  \
                                     $DJANGO_SUPERUSER_EXTRA_ARGS > /dev/null
        # Update the password for the superuser if required
        # For compatability with Docker secrets, which can only be mounted as
        # files, allow for DJANGO_SUPERUSER_PASSWORD_FILE as well
        if [ -z "$DJANGO_SUPERUSER_PASSWORD" ] && [ -f "$DJANGO_SUPERUSER_PASSWORD_FILE" ]; then
            DJANGO_SUPERUSER_PASSWORD=$(cat "$DJANGO_SUPERUSER_PASSWORD_FILE")
        fi
        if [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
            info "Setting Django superuser password"
            django-admin shell <<STDIN > /dev/null
from django.contrib.auth import get_user_model

user = get_user_model().objects.get(username='$DJANGO_SUPERUSER_USERNAME')
user.set_password('$DJANGO_SUPERUSER_PASSWORD')
user.save()
STDIN
        fi
    fi
fi

# Collect static files for serving later
info "Collecting static files"
django-admin collectstatic --no-input > /dev/null

# Create the Paste config file
info "Generating Paste config file"
# Note that we have to do this rather than using Paste variables because we want
# to have a dynamic route name in the urlmap
function django_setting {
    setting=$(django-admin shell <<< "from django.conf import settings; print(settings.$1)" || exit 1)
    # Find the first line containing an instance of the REPL string
    setting="$(echo -e "$setting" | grep ">>>")"
    # Remove the REPL string and any remaining whitespace
    echo -e "${setting//">>>"/}" | tr -d '[:space:]'
}
# Note that because gunicorn understands SCRIPT_NAME, we need to strip it from
# the STATIC_URL setting for the static app
static_url="$(django_setting STATIC_URL)"
cat > /home/gunicorn/paste.ini <<EOF
[composite:main]
use = egg:Paste#urlmap
/ = django
${static_url#"$SCRIPT_NAME"} = static

[app:django]
use = call:django_paste:app_factory
django_wsgi_application = $(django_setting WSGI_APPLICATION)

[app:static]
use = egg:Paste#static
document_root = $(django_setting STATIC_ROOT)

[server:main]
use = egg:gunicorn#main
EOF

# Run the app using gunicorn (we are already the Django user)
info "Starting gunicorn"
exec gunicorn \
    --paste /home/gunicorn/paste.ini \
    --bind 0.0.0.0:${GUNICORN_PORT:-8000} \
    --access-logfile '-' \
    --error-logfile '-' \
    --log-level ${GUNICORN_LOG_LEVEL:-info} \
    --workers ${GUNICORN_WORKERS:-1}
