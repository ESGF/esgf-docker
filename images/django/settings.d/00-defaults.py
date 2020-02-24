"""
Default settings, including security best practices.
"""

import os

# By default, don't run in DEBUG mode
DEBUG = False

# In a Docker container, ALLOWED_HOSTS is always '*' - let the proxy worry about hosts
ALLOWED_HOSTS = ['*']

# Security settings
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
CSRF_COOKIE_HTTPONLY = True
X_FRAME_OPTIONS = 'DENY'

# Allow the secret key to come from the environment or from a file (for Docker secrets)
# If not given, use a random value
if 'DJANGO_SECRET_KEY' in os.environ:
    SECRET_KEY = os.environ['DJANGO_SECRET_KEY']
elif 'DJANGO_SECRET_KEY_FILE' in os.environ:
    SECRET_KEY_FILE = os.environ['DJANGO_SECRET_KEY_FILE']
    with open(SECRET_KEY_FILE) as fh:
        SECRET_KEY = fh.read().strip()
else:
    SECRET_KEY = os.urandom(32).hex()

# All logging should go to stdout/stderr to be collected
import logging
LOG_FORMAT = '[%(levelname)s] [%(asctime)s] [%(name)s:%(lineno)s] [%(threadName)s] %(message)s'
LOGGING = {
    'version' : 1,
    'disable_existing_loggers' : False,
    'formatters' : {
        'default' : {
            'format' : LOG_FORMAT,
        },
    },
    'filters' : {
        # Logging filter that only accepts records with a level < WARNING
        # This allows us to log level >= WARNING to stderr and level < WARNING to stdout
        'less_than_warning' : {
            '()': 'django.utils.log.CallbackFilter',
            'callback': lambda record: record.levelno < logging.WARNING,
        },
    },
    'handlers' : {
        'stdout' : {
            'class' : 'logging.StreamHandler',
            'stream' : 'ext://sys.stdout',
            'formatter' : 'default',
            'filters': ['less_than_warning'],
        },
        'stderr' : {
            'class' : 'logging.StreamHandler',
            'stream' : 'ext://sys.stderr',
            'formatter' : 'default',
            'level' : 'WARNING',
        },
    },
    'loggers' : {
        '' : {
            'handlers' : ['stdout', 'stderr'],
            'level' : 'INFO',
            'propogate' : True,
        },
    },
}

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# Define the database dictionary, but don't define any databases
DATABASES = {}

# Authentication settings
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# IMPORTANT: CookieStorage (and hence FallbackStorage, which is the default) interacts
#            badly with Chrome's prefetching, causing messages to be rendered twice
#            or not at all...!
MESSAGE_STORAGE = 'django.contrib.messages.storage.session.SessionStorage'

# Default internationalization settings
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
