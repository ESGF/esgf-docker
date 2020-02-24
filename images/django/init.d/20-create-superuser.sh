#!/usr/bin/bash

set -eo pipefail

function info { echo "[info] $1"; }
function fatal { echo "[fatal] $1" 1>&2; exit 1; }

#####
## This script creates/updates the Django superuser
#####

# If not asked to create a superuser, there is nothing to do
test "${DJANGO_CREATE_SUPERUSER:-0}" -eq 0 && \
  info "Skipping Django superuser creation"
  return

# We require that username and email are set
test -z "$DJANGO_SUPERUSER_USERNAME" && \
  fatal "DJANGO_SUPERUSER_USERNAME must be set to create superuser"
test -z "$DJANGO_SUPERUSER_EMAIL" && \
  fatal "DJANGO_SUPERUSER_EMAIL must be set to create superuser"

# Test if the superuser exists
# This command exits with 0 if the user exists and 1 if it doesn't
superuser_exists="
from django.contrib.auth import get_user_model
get_user_model().objects.get(username='$DJANGO_SUPERUSER_USERNAME')
"
if django-admin shell -c "$superuser_exists" > /dev/null 2>&1; then
    info "Django superuser $DJANGO_SUPERUSER_USERNAME already exists"
else
    info "Creating Django superuser $DJANGO_SUPERUSER_USERNAME"
    django-admin createsuperuser
      --no-input
      --username "$DJANGO_SUPERUSER_USERNAME"
      --email "$DJANGO_SUPERUSER_EMAIL" > /dev/null
fi

# Update the password for the superuser if required
# Allow for the password to come from a file
if [ -z "$DJANGO_SUPERUSER_PASSWORD" ] && [ -f "$DJANGO_SUPERUSER_PASSWORD_FILE" ]; then
    DJANGO_SUPERUSER_PASSWORD=$(cat "$DJANGO_SUPERUSER_PASSWORD_FILE")
fi
if [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
    info "Setting Django superuser password"
    set_password="
from django.contrib.auth import get_user_model

user = get_user_model().objects.get(username='$DJANGO_SUPERUSER_USERNAME')
user.set_password('$DJANGO_SUPERUSER_PASSWORD')
user.save()
"
    django-admin shell -c "$set_password"
fi
