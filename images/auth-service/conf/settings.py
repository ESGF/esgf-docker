"""
Root settings file

Includes settings files from a sibling directory called settings.d.
"""

import os
from pathlib import Path

from flexi_settings import include, include_dir


base_dir = Path(__file__).resolve().parent

# First, include the defaults
include(base_dir / "defaults.py")
# Then include the user settings
include_dir(base_dir / "settings.d")
# Always include the whitenoise settings to configure static files
include(base_dir / "whitenoise.py")
