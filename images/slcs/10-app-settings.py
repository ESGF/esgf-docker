import os

from django.utils.module_loading import module_dir
import esgf_slcs_server
BASE_DIR = module_dir(esgf_slcs_server)

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'oauth2_provider',
    'bootstrap3',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'esgf_slcs_server.urls'

TEMPLATES[0]['DIRS'].append(os.path.join(BASE_DIR, 'esgf_slcs_server', 'templates'))

WSGI_APPLICATION = 'esgf_slcs_server.wsgi.application'

ESGF_USERDB_USER_SCHEMA = "esgf_security"
ESGF_USERDB_USER_TABLE = "user"

AUTHENTICATION_BACKENDS = [
    'oauth2_provider.backends.OAuth2Backend',
    'esgf_auth.backend.EsgfUserBackend'
]

STATICFILES_DIRS = [os.path.join(BASE_DIR, 'esgf_slcs_server', 'static')]

LOGIN_URL = 'accounts_login'
LOGOUT_URL = 'accounts_logout'
LOGIN_REDIRECT_URL = 'home'

BOOTSTRAP3 = {
    'success_css_class': '',
}

# OAuth provider configuration
# This expects the BASE_URL variable to be set before this file is included
CERTIFICATE_SCOPE = '{}/oauth/certificate/'.format(BASE_URL)
OAUTH2_PROVIDER = {
    'SCOPES' : {
        CERTIFICATE_SCOPE : 'Obtain short-lived certificate for user',
    },
    'DEFAULT_SCOPES' : [CERTIFICATE_SCOPE],
}

# Set the Basic Auth realm to the hostname
from urllib.parse import urlparse
BASIC_AUTH_REALM = urlparse(BASE_URL).hostname

# OnlineCA settings
from pathlib import Path
ONLINECA = {
    'TRUSTROOTS_DIR': os.environ['ESGF_CERT_DIR'],
    'USER_TO_STRING_MAPPER': 'esgf_auth.openid.django_user_to_openid',
    'SUBJECT_NAME_TEMPLATE': '/DC=esgf/CN={user}',
    'CA_CERT_PATH': '{}/slcs/ca/cert.pem'.format(os.environ['ESGF_HOME']),
    'CA_KEY_PATH': '{}/slcs/ca/key.pem'.format(os.environ['ESGF_HOME']),
}
