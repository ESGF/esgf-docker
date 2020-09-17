#!/opt/conda/bin/python

"""
This script configures a Django superuser.
"""

def main():
    import os

    # Only create the superuser if a username is specified
    if 'DJANGO_SUPERUSER_USERNAME' not in os.environ:
        print("[info] Skipping Django superuser configuration - no superuser specified")
        return

    # Configure Django before attempting to read a model
    import django
    django.setup()

    from django.core.exceptions import ObjectDoesNotExist
    from django.contrib.auth import get_user_model

    username = os.environ['DJANGO_SUPERUSER_USERNAME']
    print(f"[info] Configuring Django superuser - {username}")

    # Create or update the superuser
    User = get_user_model()
    try:
        user = User.objects.get(username = username)
    except ObjectDoesNotExist:
        user = User.objects.create_superuser(username)
    else:
        if not user.is_staff or not user.is_superuser:
            user.is_staff = True
            user.is_superuser = True
            user.save()

    # Update the password if specified
    # We allow it to come either from a file specified by an environment variable,
    # or directly from the environment
    superuser_password = None
    if 'DJANGO_SUPERUSER_PASSWORD' in os.environ:
        superuser_password = os.environ['DJANGO_SUPERUSER_PASSWORD'].strip()
    elif 'DJANGO_SUPERUSER_PASSWORD_FILE' in os.environ:
        with open(os.environ['DJANGO_SUPERUSER_PASSWORD_FILE']) as fh:
            superuser_password = fh.read().strip()
    if superuser_password:
        print("[info] Setting Django superuser password")
        user.set_password(superuser_password)
        user.save()
    else:
        print("[info] No Django superuser password specified")


if __name__ == "__main__":
    main()
