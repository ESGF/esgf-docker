#!/usr/bin/bash

set -eo pipefail

echo "[info] Running CoG setup"
python "$COG_INSTALL_DIR/setup.py" setup_cog --esgf=true
