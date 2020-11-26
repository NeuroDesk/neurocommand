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
import  distutils.dir_util

from neurodesk.build_menu import apps_from_json
from neurodesk.build_menu import add_vnm_menu

logging.basicConfig(level=logging.INFO, format='%(levelname)s | %(message)s')
logger = logging.getLogger(__name__)

# CLI signal handler for safe Ctrl-C
def signal_handler(signal, frame):
        logging.info('\nExiting ...')
        sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)

# Global settings
CONFIG_FILE = 'neurodesk/config.ini'
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
    parser.add_argument('--edit', action="store_true", default=False)
    parser.add_argument('--cli', action="store_true", default=False)
    args = parser.parse_args()
    return args


def vnm_xml(xml: Path, newxml: Path) -> None:
    oldtag = '<Menu>'
    newtag = '<MergeFile>vnm-applications.menu</MergeFile>'
    tagcount = 0
    replace = True
    
    with open(xml, "r") as fh:
        lines = fh.readlines()
        for line in lines:
            if newtag in line:
                replace = False
                break

    with open(newxml, "w") as fh:
        for line in lines:
            if replace and oldtag in line:
                tagcount += 1
                if tagcount == 2:
                    fh.write(re.sub(f'{oldtag}', f'{newtag}\n\t{oldtag}', line))
                else:
                    fh.write(line)
            else:
                fh.write(line)
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

    config['vnm'] = {
        'deskenv': '', 
        'installdir': '',
        'appmenu': '',
        'appdir': '',
        'deskdir': '', 
        'edit': '',
        'sh_prefix': ''
        }
    config.read(CONFIG_FILE)
    if args.lxde:
        config['vnm']['deskenv'] = 'lxde'
        config['vnm']['appmenu'] = DEFAULT_PATHS['lxde']['appmenu']
        config['vnm']['appdir'] = DEFAULT_PATHS['lxde']['appdir']
        config['vnm']['deskdir'] = DEFAULT_PATHS['lxde']['deskdir']
        config['vnm']['edit'] = 'n'

    if args.edit:
        config['vnm']['edit'] = 'y'

    if args.cli:
        print('installing in command line mode without desktop menus')
        config['vnm']['edit'] = 'y'

    if args.init:
        while not config['vnm']['deskenv'] in ["lxde", "mate"]:
            config['vnm']['deskenv'] = input(f'Desktop Env? [lxde/mate]: ')
            config['vnm']['deskenv'] = config['vnm']['deskenv'].lower()
            if config['vnm']['deskenv'] == "":
                logging.info('Defaulting to lxde')
                config['vnm']['deskenv'] = "lxde"
        config['vnm']['installdir'] = input('installdir: ') or config['vnm']['installdir']
        config['vnm']['appmenu'] = input('appmenu: ') or config['vnm']['appmenu']
        config['vnm']['appdir'] = input('appdir: ') or config['vnm']['appdir']
        config['vnm']['deskdir'] = input('deskdir: ') or config['vnm']['deskdir']
        while not config['vnm']['edit'] in ["y", "n"]:
            config['vnm']['edit'] = input(f'Edit system files? [Y/n]: ')
            config['vnm']['edit'] = config['vnm']['edit'].lower()
            if config['vnm']['edit'] == "":
                config['vnm']['edit'] = "y"

    try:
        installdir = Path(config['vnm']['installdir']).expanduser().resolve(strict=False)
        if installdir == Path.cwd():
            installdir = Path.cwd()/'local'
        installdir.mkdir(parents=True, exist_ok=True)
    except PermissionError:
        logging.error(f'PermissionError creating installdir [{installdir}]')
        logging.error('Exiting ...')
        sys.exit()
    
    if not args.cli:
        try:
            appmenu = Path(config['vnm']['appmenu']).expanduser()
            appmenu.resolve(strict=True)
            et.parse(appmenu)
        except et.ParseError:
            logging.error(f'InvalidXMLError with appmenu [{appmenu}]')
            logging.error('Exiting ...')
            sys.exit()

        try:
            appdir = Path(config['vnm']['appdir']).expanduser()
            appdir.resolve(strict=True)
            next(appdir.glob("*.desktop"))
        except StopIteration:
            logging.error(f'.desktop files not found in appdir [{appdir}]')
            logging.error('Exiting ...')
            sys.exit()

        try:
            deskdir = Path(config['vnm']['deskdir']).expanduser()
            deskdir.resolve(strict=True)
            next(deskdir.glob("*.directory"))
        except StopIteration:
            logging.error(f'.directory files not found in deskdir [{deskdir}]')
            logging.error('Exiting ...')
            sys.exit()

        config['vnm']['appmenu'] = str(appmenu)
        config['vnm']['appdir'] = str(appdir)
        config['vnm']['deskdir'] = str(deskdir)
    
    config['vnm']['installdir'] = str(installdir)

    with open(CONFIG_FILE, 'w+') as fh:
        config.write(fh)

    appmenu_template = Path('neurodesk/vnm-applications.menu.template').resolve(strict=True)
    
    vnm_appmenu = installdir/'vnm-applications.menu'
    # vnm_deskdir = installdir/'desktop-directories'
    

    shutil.copy2(appmenu_template, vnm_appmenu)
    shutil.copy2('neurodesk/fetch_and_run.sh', installdir)
    shutil.copy2('neurodesk/fetch_containers.sh', installdir)
    shutil.copy2('neurodesk/configparser.sh', installdir)
    shutil.copy2('neurodesk/config.ini', installdir)
    distutils.dir_util.copy_tree('neurodesk/transparent-singularity', str(installdir/'transparent-singularity'))
    os.chmod(installdir/'fetch_and_run.sh', 0o755)
    os.chmod(installdir/'fetch_containers.sh', 0o755)
    os.chmod(installdir/'configparser.sh', 0o755)

    if not args.cli and appmenu:
        new_appmenu = installdir/appmenu.name
        vnm_xml(appmenu, new_appmenu)

    appsjson = Path('neurodesk/apps.json').resolve(strict=True)
    (installdir/'icons').mkdir(exist_ok=True)
    apps_from_json(args.cli, config['vnm']['deskenv'], installdir, appsjson, config['vnm']['sh_prefix'])
    if not args.cli:
        add_vnm_menu(installdir, 'VNM Neuroimaging')

    # Remove any symlinks from local appdir
    # Prevents symlink recursion
    vnm_appdir = installdir/'applications'
    for file in vnm_appdir.glob('*'):
        if file.is_symlink():
            os.unlink(file)


if __name__ == "__main__":
    main()
