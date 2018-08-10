#!/usr/bin/env bash

set -eo pipefail

function info { echo "[INFO] $1"; }
function error { echo "[ERROR] $1" 1>&2; exit 1; }

#####
## This script sets up Django before starting the WSGI server
#####

[ -z "$DJANGO_SETTINGS_MODULE" ] && error "DJANGO_SETTINGS_MODULE must be set"

# Run the customisations
info "Running customisations"
if [ -d "/django-init.d" ]; then
    for file in $(find /django-init.d/ -mindepth 1 -type f -executable | sort -n); do
        info "  Running $file"
        case "$file" in
            *.sh) . $file ;;
            *) eval $file ;;
        esac
    done
fi

# Make sure the trusted certificates have been updated
info "Updating trusted certificates"
# Combine the trusted certificates into a single bundle and make sure Python uses it
cat /etc/ssl/certs/ca-certificates.crt > /var/run/django/conf/trust-bundle.pem
cat /esg/certificates/esg-trust-bundle.pem >> /var/run/django/conf/trust-bundle.pem
export SSL_CERT_FILE=/var/run/django/conf/trust-bundle.pem
# Also set the requests-specific environment variable, as it doesn't respect SSL_CERT_FILE
export REQUESTS_CA_BUNDLE="${SSL_CERT_FILE}"

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
static_url="${static_url#"${SCRIPT_NAME:-""}"}"
cat > /var/run/django/conf/paste.ini <<EOF
[composite:main]
use = egg:Paste#urlmap
/ = django
${static_url} = static

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
    --paste /var/run/django/conf/paste.ini \
    --bind 0.0.0.0:${GUNICORN_PORT:-8000} \
    --access-logfile '-' \
    --error-logfile '-' \
    --log-level ${GUNICORN_LOG_LEVEL:-info} \
    --workers ${GUNICORN_WORKERS:-4}
