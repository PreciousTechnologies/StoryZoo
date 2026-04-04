import os
from pathlib import Path

from dotenv import load_dotenv

# Ensure local .env changes take effect even if old variables exist in shell.
load_dotenv(override=True)

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/5.2/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'dev-secret-key-change-me')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.getenv('DJANGO_DEBUG', 'true').lower() == 'true'

ALLOWED_HOSTS = [h.strip() for h in os.getenv('DJANGO_ALLOWED_HOSTS', '*').split(',') if h.strip()]
CSRF_TRUSTED_ORIGINS = [
    o.strip() for o in os.getenv('DJANGO_CSRF_TRUSTED_ORIGINS', '').split(',') if o.strip()
]


# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'corsheaders',
    'rest_framework',
    'rest_framework.authtoken',
    'stories',
    'payments',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'


# Database
# https://docs.djangoproject.com/en/5.2/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('POSTGRES_DB', 'storyzoo'),
        'USER': os.getenv('POSTGRES_USER', 'postgres'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD', ''),
        'HOST': os.getenv('POSTGRES_HOST', '127.0.0.1'),
        'PORT': os.getenv('POSTGRES_PORT', '5432'),
    }
}


# Password validation
# https://docs.djangoproject.com/en/5.2/ref/settings/#auth-password-validators

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


# Internationalization
# https://docs.djangoproject.com/en/5.2/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.2/howto/static-files/

STATIC_URL = 'static/'
STATIC_ROOT = Path(os.getenv('DJANGO_STATIC_ROOT', str(BASE_DIR / 'staticfiles')))
MEDIA_URL = '/media/'
MEDIA_ROOT = Path(os.getenv('DJANGO_MEDIA_ROOT', str(BASE_DIR / 'media')))

CORS_ALLOW_ALL_ORIGINS = os.getenv('CORS_ALLOW_ALL', 'true').lower() == 'true'

if not DEBUG:
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SECURE_SSL_REDIRECT = os.getenv('DJANGO_SECURE_SSL_REDIRECT', 'true').lower() == 'true'
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True

PIPER_EXECUTABLE = os.getenv('PIPER_EXECUTABLE', r'C:\piper\piper.exe')
PIPER_MODEL_PATH = os.getenv('PIPER_MODEL_PATH', r'C:\piper\models\en_US-lessac-medium.onnx')
PIPER_MODEL_PATH_EN = os.getenv('PIPER_MODEL_PATH_EN', PIPER_MODEL_PATH)
PIPER_MODEL_PATH_SW = os.getenv('PIPER_MODEL_PATH_SW', r'C:\piper\models\sw_CD-lanfrica-medium.onnx')
PIPER_VOICE_MODELS = {
    'en_US-lessac-medium': PIPER_MODEL_PATH_EN,
    'sw_CD-lanfrica-medium': PIPER_MODEL_PATH_SW,
}
PIPER_LANGUAGE_DEFAULTS = {
    'en': 'en_US-lessac-medium',
    'sw': 'sw_CD-lanfrica-medium',
}
PIPER_TIMEOUT_SECONDS = int(os.getenv('PIPER_TIMEOUT_SECONDS', '120'))
GOOGLE_OAUTH_CLIENT_ID = os.getenv('GOOGLE_OAUTH_CLIENT_ID', '')

EMAIL_BACKEND = os.getenv('EMAIL_BACKEND', 'django.core.mail.backends.smtp.EmailBackend')
EMAIL_HOST = os.getenv('EMAIL_HOST', 'smtp.gmail.com')
EMAIL_PORT = int(os.getenv('EMAIL_PORT', '587'))
EMAIL_HOST_USER = os.getenv('EMAIL_HOST_USER', '')
EMAIL_HOST_PASSWORD = os.getenv('EMAIL_HOST_PASSWORD', '').replace(' ', '')
EMAIL_USE_TLS = os.getenv('EMAIL_USE_TLS', 'true').lower() == 'true'
DEFAULT_FROM_EMAIL = os.getenv('DEFAULT_FROM_EMAIL', EMAIL_HOST_USER or 'noreply@storyzoo.local')
EMAIL_OTP_TTL_SECONDS = int(os.getenv('EMAIL_OTP_TTL_SECONDS', '600'))

# Pesapal
PESAPAL_BASE_URL = os.getenv('PESAPAL_BASE_URL', 'https://cybqa.pesapal.com/pesapalv3')
PESAPAL_CONSUMER_KEY = os.getenv('PESAPAL_CONSUMER_KEY', '')
PESAPAL_CONSUMER_SECRET = os.getenv('PESAPAL_CONSUMER_SECRET', '')
PESAPAL_CALLBACK_URL = os.getenv('PESAPAL_CALLBACK_URL', '')
PESAPAL_IPN_URL = os.getenv('PESAPAL_IPN_URL', PESAPAL_CALLBACK_URL)
PESAPAL_IPN_ID = os.getenv('PESAPAL_IPN_ID', '')
PESAPAL_IPN_TYPE = os.getenv('PESAPAL_IPN_TYPE', 'POST')
PESAPAL_CURRENCY = os.getenv('PESAPAL_CURRENCY', 'TZS')
PESAPAL_PAYMENT_DESCRIPTION = os.getenv('PESAPAL_PAYMENT_DESCRIPTION', 'Story Zoo Premium Subscription')
PESAPAL_TIMEOUT_SECONDS = int(os.getenv('PESAPAL_TIMEOUT_SECONDS', '30'))

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
        'rest_framework.parsers.FormParser',
        'rest_framework.parsers.MultiPartParser',
    ],
}

# Default primary key field type
# https://docs.djangoproject.com/en/5.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
