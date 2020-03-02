#!/usr/bin/bash

set -eo pipefail

echo "[info] Collecting static files"
django-admin collectstatic --no-input > /dev/null
