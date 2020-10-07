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

from neurodesk.build_menu import apps_from_json

logging.basicConfig(level=logging.INFO, format='%(levelname)s | %(message)s')
logger = logging.getLogger(__name__)

# CLI signal handler for safe Ctrl-C
def signal_handler(signal, frame):
        logging.info('\nExiting ...')
        sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)

# Global settings
CONFIG_FILE = 'config.ini'
DEFAULT_PATHS = {}
DEFAULT_PATHS['lxde'] = {
    'appmenu': '/etc/xdg/menus/lxde-applications.menu',
    'appdir': '/usr/share/applications/',
    'deskdir': '/usr/share/desktop-directories/'
}

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--init', action="store_true", default=False)
    parser.add_argument('--lxde', action="store_true", default=False)
    args = parser.parse_args()
    return args


def vnm_xml(xml: Path, newxml: Path) -> None:
    oldtag = '<DefaultMergeDirs/>'
    newtag = '<MergeFile>vnm-applications.menu</MergeFile>'
    with open(xml, "r") as fh:
        lines = fh.readlines()
    with open(newxml, "w") as fh:
        for line in lines:
            fh.write(re.sub(f'{oldtag}', f'{oldtag}\n\n\t{newtag}', line))
    try:
        et.parse(newxml)
    except et.ParseError:
        logging.error(f'InvalidXMLError with appmenu [{newxml}]')
        logging.error('Exiting ...')
        sys.exit()



def main():
    if os.name != 'posix':
        raise OSError

    args = get_args()
    config = configparser.ConfigParser()

    config['vnm'] = {'installdir': '', 'appmenu': '', 'appdir': '', 'deskdir': ''}
    config.read(CONFIG_FILE)

    if args.lxde:
        config['vnm']['appmenu'] = DEFAULT_PATHS['lxde']['appmenu']
        config['vnm']['appdir'] = DEFAULT_PATHS['lxde']['appdir']
        config['vnm']['deskdir'] = DEFAULT_PATHS['lxde']['deskdir']

    if args.init:
        config['vnm']['installdir'] = input(f'installdir: ') or config['vnm']['installdir']
        config['vnm']['appmenu'] = input(f'appmenu: ') or config['vnm']['appmenu']
        config['vnm']['appdir'] = input(f'appdir: ') or config['vnm']['appdir']
        config['vnm']['deskdir'] = input(f'deskdir: ') or config['vnm']['deskdir']

    try:
        installdir = Path(config['vnm']['installdir']).expanduser().resolve(strict=False)
        if installdir == Path.cwd():
            installdir = Path.cwd()/'installdir'
        installdir.mkdir(parents=True, exist_ok=True)
    except PermissionError:
        logging.error(f'PermissionError creating installdir [{installdir}]')
        logging.error('Exiting ...')
        sys.exit()
    
    try:
        appmenu = Path(config['vnm']['appmenu']).expanduser().resolve(strict=True)
        et.parse(appmenu)
    except et.ParseError:
        logging.error(f'InvalidXMLError with appmenu [{appmenu}]')
        logging.error('Exiting ...')
        sys.exit()

    try:
        appdir = Path(config['vnm']['appdir']).expanduser().resolve(strict=True)
        next(appdir.glob("*.desktop"))
    except StopIteration:
        logging.error(f'.desktop files not found in appdir [{appdir}]')
        logging.error('Exiting ...')
        sys.exit()

    try:
        deskdir = Path(config['vnm']['deskdir']).expanduser().resolve(strict=True)
        next(deskdir.glob("*.directory"))
    except StopIteration:
        logging.error(f'.directory files not found in deskdir [{deskdir}]')
        logging.error('Exiting ...')
        sys.exit()

    config['vnm']['installdir'] = str(installdir)
    config['vnm']['appmenu'] = str(appmenu)
    config['vnm']['appdir'] = str(appdir)
    config['vnm']['deskdir'] = str(deskdir)

    with open(CONFIG_FILE, 'w+') as fh:
        config.write(fh)

    appmenu_template = Path('neurodesk/vnm-applications.menu.template').resolve(strict=True)
    new_appmenu = installdir/appmenu.name
    vnm_appmenu = installdir/'vnm-applications.menu'
    vnm_deskdir = installdir/'desktop-directories'
    vnm_appdir = installdir/'applications'

    shutil.copy2(appmenu_template, vnm_appmenu)
    vnm_xml(appmenu, new_appmenu)

    appsjson = Path('neurodesk/apps.json').resolve(strict=True)
    apps_from_json(installdir, appsjson)


if __name__ == "__main__":
    main()