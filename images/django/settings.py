"""
Root settings file. Just includes settings files from a sibling directory
called settings.d.
"""

from pathlib import Path
from flexi_settings import include_dir
include_dir(Path(__file__).resolve().parent / 'settings.d')
