import sys
import argparse
import configparser
from pathlib import Path
import os
import signal
import sys
import tempfile
import xml.etree.ElementTree as et
import logging
import shutil
import stat
import re

from neurodesk.build_menu import build_menu
from neurodesk.build_menu import vnm_xml

logging.basicConfig(level=logging.INFO, format='%(levelname)s | %(message)s')
logger = logging.getLogger(__name__)

# CLI signal handler for safe Ctrl-C
def signal_handler(signal, frame):
        logging.info('\nExiting ...')
        sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)

# Global settings
CONFIG_FILE = 'config.ini'
# DEFAULT_PATHS = {}
# DEFAULT_PATHS['lxde'] = {
#     'appmenu': '/etc/xdg/menus/lxde-applications.menu',
#     'appdir': '/usr/share/applications/',
#     'deskdir': '/usr/share/desktop-directories/'
# }


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--installdir', action="store")
    parser.add_argument('--deskenv', action="store")
    parser.add_argument('--appmenu', action="store")
    parser.add_argument('--appdir', action="store")
    parser.add_argument('--deskdir', action="store")
    parser.add_argument('--edit', action="store")
    # parser.add_argument('--edit', action="store_true", default=False)
    # parser.add_argument('--lxde', action="store_true", default=False)
    # parser.add_argument('--cli', action="store_true", default=False)

    args = parser.parse_args()
    return args


def main():
    if os.name != 'posix':
        raise OSError

    args = get_args()
    config = configparser.ConfigParser()

    config['vnm'] = {
        'deskenv': '', 
        'installdir': '',
        'appmenu': '',
        'appdir': '', 
        'deskdir': '', 
        'edit': '',
        'sh_prefix': '',
        'singularity_opts': ''
        }
    config.read(CONFIG_FILE)

    if args.installdir:
        config['vnm']['installdir'] = str(args.installdir)
    if args.deskenv:
        config['vnm']['deskenv'] = str(args.deskenv)
    if args.appmenu:
        config['vnm']['appmenu'] = str(args.appmenu)
    if args.appdir:
        config['vnm']['appdir'] = str(args.appdir)
    if args.deskdir:
        config['vnm']['deskdir'] = str(args.deskdir)
    if args.edit:
        config['vnm']['edit'] = str(args.edit)

    with open(CONFIG_FILE, 'w+') as fh:
        config.write(fh)

    installdir = Path(config['vnm']['installdir']).resolve(strict=True)

    if not config['vnm']['deskenv'] == 'cli' and config['vnm']['appmenu']:
        appmenu = Path(config['vnm']['appmenu'])
        appmenu_template = installdir/'local-applications.menu.template'
        new_appmenu = installdir/appmenu.name
        vnm_xml(appmenu_template, new_appmenu)

    build_menu(installdir, config['vnm']['deskenv'], config['vnm']['sh_prefix'])


if __name__ == "__main__":
    main()

