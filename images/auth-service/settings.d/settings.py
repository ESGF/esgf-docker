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
SESSION_COOKIE_SECURE = False
