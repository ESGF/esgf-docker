#!/usr/bin/bash

# Extract the WSGI application from the Django settings
echo "[info] Extracting WSGI application from Django settings"
# The Django WSGI_APPLICATION setting has all dots, whereas gunicorn expects "py.mod:var"
# So we need to replace the right-most dot with a colon
wsgi_application_script="
from django.conf import settings
print(settings.WSGI_APPLICATION[::-1].replace('.', ':', 1)[::-1])
"
WSGI_APPLICATION="$(django-admin shell -c "$wsgi_application_script")"

echo "[info] Running WSGI application $WSGI_APPLICATION"
exec /usr/local/bin/wsgi-serve.sh $WSGI_APPLICATION
