#!/usr/bin/bash

set -eo pipefail

echo "[info] Running database migrations"
django-admin migrate --no-input > /dev/null
