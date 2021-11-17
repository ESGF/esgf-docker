import re

from django.conf import settings
from urllib.parse import urlparse

from authenticate.utils import get_requested_resource

# Application definition

INSTALLED_APPS = [
    'django.contrib.staticfiles',
    'django.contrib.sessions',
    'authenticate',
]

ROOT_URLCONF = 'auth_service.urls'
WSGI_APPLICATION = 'auth_service.wsgi.application'

# Use a non database session engine
SESSION_ENGINE = 'django.contrib.sessions.backends.signed_cookies'
SESSION_COOKIE_SECURE = False

# Authorization bypass function for exempt paths
def is_exempt(request):

    if not settings.AUTHORIZATION_EXEMPT_PATHS:
        return False

    resource = get_requested_resource(request)
    if resource:

        # Check exempt path patterns against requested URL
        path = urlparse(resource).path.lstrip("/")
        for expr in settings.AUTHORIZATION_EXEMPT_PATHS:
            if re.compile(expr).match(path):
                return True

AUTHORIZATION_EXEMPT_PATHS = [] # e.g. [".*"]
AUTHORIZATION_EXEMPT_FILTER = is_exempt
