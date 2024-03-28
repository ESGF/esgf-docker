#!/opt/conda/bin/python

"""
This script runs database migrations, but only if there are databases configured.
"""

import django
from django.conf import settings
from django.core import management


def main():
    # First, make sure we have run the Django setup
    django.setup()

    # Then run the migrations if required
    if settings.DATABASES:
        print(f"[info] Running database migrations")
        management.call_command('migrate', interactive = False)
    else:
        print(f"[warn] Skipping database migrations - no databases configured")


if __name__ == "__main__":
    main()
