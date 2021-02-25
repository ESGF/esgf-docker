#!/usr/bin/bash

# Allows for the specification of WSGI application using an environment variable

echo "[info] Starting gunicorn"
exec gunicorn --config /etc/gunicorn/conf.py "$@"
