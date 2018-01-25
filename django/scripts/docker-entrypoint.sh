#! /usr/bin/env bash

set -x

# Configure settings module to the first argument
export DJANGO_SETTINGS_MODULE="$1"

# Execute customisations from /django-init.d before doing anything
if [ -d "/django-init.d" ]; then
    for file in $(find /django-init.d/ -mindepth 1 -type f -executable | sort -n); do
        # All customisations have access to the exported environment variables only,
        # whether they are bash, python or otherwise
        eval $file || exit 1
    done
fi

# Run database migrations
django-admin migrate --no-input || exit 1

# Create Django superuser if required
if [ "${DJANGO_CREATE_SUPERUSER:-0}" -eq 1 ]; then
    # We require that username and email exist
    if [ -z "$DJANGO_SUPERUSER_USERNAME" ]; then
        echo "[ERROR] DJANGO_SUPERUSER_USERNAME must be set to create superuser" 1>&2
        exit 1
    fi
    if [ -z "$DJANGO_SUPERUSER_EMAIL" ]; then
        echo "[ERROR] DJANGO_SUPERUSER_EMAIL must be set to create superuser" 1>&2
        exit 1
    fi
    # This command exits with a non-zero exit code if the user already exists
    django-admin shell <<STDIN
import sys
from django.contrib.auth import get_user_model

if get_user_model().objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    sys.exit(1)
STDIN
    # A zero exit status means the user needs to be created
    if [ "$?" -eq 0 ]; then
        # Create the superuser with an unusable password
        django-admin createsuperuser --no-input  \
                                     --username "$DJANGO_SUPERUSER_USERNAME"  \
                                     --email "$DJANGO_SUPERUSER_EMAIL"  \
                                     $DJANGO_SUPERUSER_EXTRA_ARGS || exit 1
        # Update the password for the superuser if required
        # For compatability with Docker secrets, which can only be mounted as
        # files, allow for DJANGO_SUPERUSER_PASSWORD_FILE as well
        if [ -z "$DJANGO_SUPERUSER_PASSWORD" ] && [ -f "$DJANGO_SUPERUSER_PASSWORD_FILE" ]; then
            DJANGO_SUPERUSER_PASSWORD=$(cat "$DJANGO_SUPERUSER_PASSWORD_FILE")
        fi
        if [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
            django-admin shell <<STDIN || exit 1
from django.contrib.auth import get_user_model

user = get_user_model().objects.get(username='$DJANGO_SUPERUSER_USERNAME')
user.set_password('$DJANGO_SUPERUSER_PASSWORD')
user.save()
STDIN
        fi
    fi
fi

# Collect static files for serving later
django-admin collectstatic --no-input --clear || exit 1

# Create the Paste config file
# Note that we have to do this rather than using Paste variables because we want
# to have a dynamic route name in the urlmap
function django_setting {
    setting=$(django-admin shell <<< "from django.conf import settings; print(settings.$1)" || exit 1)
    # Remove any instances of the REPL string and any remaining whitespace
    echo -e "${setting//">>>"/}" | tr -d '[:space:]'
}
# Note that because gunicorn understands SCRIPT_NAME, we need to strip it from
# the STATIC_URL setting for the static app
static_url=$(django_setting STATIC_URL)
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

# Run the app with gunicorn
exec gunicorn --paste /home/gunicorn/paste.ini \
              --bind 0.0.0.0:${GUNICORN_PORT:-8000} \
              --access-logfile '-' \
              --error-logfile '-' \
              --log-level ${GUNICORN_LOG_LEVEL:-info} \
              --workers ${GUNICORN_WORKERS:-4}
