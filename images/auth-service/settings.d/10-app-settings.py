# Application definition

INSTALLED_APPS = [
    'django.contrib.staticfiles',
    'django.contrib.sessions',
    'authenticate',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'authenticate.oauth2.middleware.BearerTokenAuthenticationMiddleware',
    'authenticate.oidc.middleware.OpenIDConnectAuthenticationMiddleware',
    'authorize.middleware.SAMLAuthorizationMiddleware',
]

ROOT_URLCONF = 'auth_service.urls'
WSGI_APPLICATION = 'auth_service.wsgi.application'

# Use a non database session engine
SESSION_ENGINE = 'django.contrib.sessions.backends.signed_cookies'

# Authlib settings

OAUTH_CLIENT_ID = ""
OAUTH_CLIENT_SECRET = ""
OAUTH_TOKEN_URL = ""
OAUTH_TOKEN_INTROSPECT_URL = ""

OIDC_BACKEND_CLIENT_NAME = "mybackend"
AUTHLIB_OAUTH_CLIENTS = {
    OIDC_BACKEND_CLIENT_NAME: {
        "client_id": OAUTH_CLIENT_ID,
        "client_secret": OAUTH_CLIENT_SECRET,
        "authorize_url": "",
        "userinfo_endpoint": "",
        "server_metadata_url": "",
        "client_kwargs": {"scope": "openid profile email"}
    }
}

# Athorization settings

RESOURCE_SERVER_URI = ""
ATTRIBUTE_SERVICE_URL = ""
AUTHORIZATION_SERVICE_URL = ""
