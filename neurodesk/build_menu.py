"""Generate the menu items."""
import configparser
import json
import os
from pathlib import Path
import re
from typing import Text
import xml.etree.ElementTree as et
from xml.dom import minidom
import shutil
import logging

def add_menu(installdir: Path, name: Text) -> None:
    """Add a submenu to 'VNM' menu.

    Parameters
    ----------
    name : Text
        The name of the submenu.
    """
    logging.info(f"Adding submenu for '{name}'")
    icon_path = installdir/f"icons/{name.split()[0]}.png"
    icon_src = (Path(__file__).parent/'icons'/icon_path.name)
    try:
        shutil.copy2(icon_src, icon_path)
    except FileNotFoundError:
        logging.warning(f'{icon_src} not found')
        icon_src = (Path(__file__).parent/'icons/vnm.png')
        shutil.copy2(icon_src, icon_path)
    # Generate `.directory` file
    entry = configparser.ConfigParser()
    entry.optionxform = str
    entry["Desktop Entry"] = {
        "Name": name,
        "Comment": name,
        "Icon": icon_path,
        "Type": "Directory",
    }
    directories_path = installdir/"desktop-directories"
    if not os.path.exists(directories_path):
        os.makedirs(directories_path)
    directory_name = f"vnm-{name.lower().replace(' ', '-')}.directory"
    with open(Path(f"{directories_path}/{directory_name}"), "w",) as directory_file:
        entry.write(directory_file, space_around_delimiters=False)
    # Add entry to `.menu` file
    menu_path = installdir/"vnm-applications.menu"
    with open(menu_path, "r") as xml_file:
        s = xml_file.read()
    s = re.sub(r"\s+(?=<)", "", s)
    root = et.fromstring(s)
    menu_el = root.findall("./Menu")[0]
    sub_el = et.SubElement(menu_el, "Menu")
    name_el = et.SubElement(sub_el, "Name")
    name_el.text = name.capitalize()
    dir_el = et.SubElement(sub_el, "Directory")
    dir_el.text = f'vnm/{directory_name}'
    include_el = et.SubElement(sub_el, "Include")
    and_el = et.SubElement(include_el, "And")
    cat_el = et.SubElement(and_el, "Category")
    cat_el.text = name.replace(" ", "-")
    cat_el.text = f"vnm-{cat_el.text}"
    xmlstr = minidom.parseString(et.tostring(root)).toprettyxml(indent="\t")
    with open(menu_path, "w") as f:
        f.write('<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"\n ')
        f.write('"http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">\n\n')
        f.write(xmlstr[xmlstr.find("?>") + 3 :])
    os.chmod(menu_path, 0o644)


class VNMApp:
    def __init__(
        self,
        deskenv: Text,
        installdir: Path,
        sh_prefix: Text,
        name: Text,
        version: Text,
        category: Text,
        exec: Text = "",
        terminal: bool = True
        ):
        """Add an application to the menu.

        Parameters
        ----------
        name : Text
            The name of the application.
        version : Text
            The version of the applciation.
        exec : Text
            The command to run when clicking on the application item.
        category : Text
            The category defining the menu in which the application must be added.
        terminal : bool
            If set to ``True``, a terminal is opened when launching the application.
        """
        self.deskenv = deskenv
        self.installdir = installdir
        self.sh_prefix = sh_prefix
        self.name = name
        self.version= version
        self.category = category
        self.exec = exec #TODO change exec to safer variable name
        self.terminal = terminal

    def app_names(self):
        self.basename = f"vnm-{self.name.lower().replace(' ', '-').replace('.', '_')}"
        self.category = f"vnm-{self.category}"
        if self.exec:
            # assumes that executable name is before the dash and after the dash the normal container name and version
            self.container_name = self.name.split("-")[1]
            self.exec_name = self.name.split("-")[0] + " " + self.name.split("-")[1].split(" ")[1]
        else: 
            self.container_name = self.name
            self.exec_name = self.name

    def add_app_sh(self):
        fetch_and_run_sh = self.installdir/"fetch_and_run.sh"
        self.bin_path = self.installdir/"bin"
        self.bin_path.mkdir(exist_ok=True)
        self.sh_path = self.bin_path/f"{self.basename}.sh"
        with open(self.sh_path, "w",) as self.sh_file:
            self.sh_file.write("#!/usr/bin/env bash\n")
            self.sh_file.write(f"{self.sh_prefix} ")
            if self.deskenv == 'mate':
                self.sh_file.write(f"{str(fetch_and_run_sh)} {self.container_name} {self.version} {self.exec}")
            else:
                self.sh_file.write(f"{str(fetch_and_run_sh)} {self.container_name} {self.version} {self.exec}")
            self.sh_file.write('\n')
        os.chmod(self.sh_path, 0o755)

    def add_app_menu(self) -> None:
        icon_path = self.installdir/f"icons/{self.name.split()[0]}.png"
        icon_src = Path(__file__).parent/'icons'/icon_path.name
        try:
            shutil.copy2(icon_src, icon_path)
        except FileNotFoundError:
            logging.warning(f'{icon_src} not found')
            icon_src = (Path(__file__).parent/'icons/vnm.png')
            shutil.copy2(icon_src, icon_path)
        entry = configparser.ConfigParser()
        entry.optionxform = str

        if self.deskenv == 'mate':
            entry["Desktop Entry"] = {
                "Name": self.exec_name,
                "GenericName": self.exec_name,
                "Comment": self.name + " " + self.version,
                "Exec": f"mate-terminal --window --title \"{self.name}\" -e \'/bin/bash {str(self.sh_path)}\'",
                "Icon": icon_path,
                "Type": "Application",
                "Categories": self.category
            }
        else:
            entry["Desktop Entry"] = {
                "Name": self.exec_name,
                "GenericName": self.exec_name,
                "Comment": self.name + " " + self.version,
                "Exec": str(self.sh_path),
                "Icon": icon_path,
                "Type": "Application",
                "Categories": self.category,
                "Terminal": str(self.terminal).lower()
            }

        applications_path = self.installdir/"applications"
        applications_path.mkdir(exist_ok=True)
        desktop_path = applications_path/f"{self.basename}.desktop"

        with open(desktop_path, "w",) as desktop_file:
            entry.write(desktop_file, space_around_delimiters=False)
        os.chmod(desktop_path, 0o644)


def apps_from_json(cli, deskenv: Text, installdir: Path, appsjson: Path, sh_prefix='')  -> None:
    # Read applications file
    with open(appsjson, "r") as json_file:
        menu_entries = json.load(json_file)

    for menu_name, menu_data in menu_entries.items():
        # Add submenu
        if not cli:
            add_menu(installdir, menu_name)
        for app_name, app_data in menu_data.get("apps", {}).items():
            app = VNMApp(
                deskenv=deskenv,
                installdir=installdir,
                sh_prefix=sh_prefix,
                name=app_name,
                category=menu_name.replace(" ", "-"),
                **app_data)
            app.app_names()
            app.add_app_sh()
            if not cli:
                app.add_app_menu()

def add_vnm_menu(installdir: Path, name: Text) -> None:
    logging.info(f"Adding submenu for '{name}'")
    icon_path = installdir/"icons/vnm.png"
    icon_src = Path(__file__).parent/'icons/vnm.png'
    shutil.copy2(icon_src, icon_path)

    # Generate `.directory` file
    entry = configparser.ConfigParser()
    entry.optionxform = str
    entry["Desktop Entry"] = {
        "Name": name,
        "Comment": name,
        "Icon": icon_path,
        "Type": "Directory",
    }
    directories_path = installdir/"desktop-directories"
    if not os.path.exists(directories_path):
        os.makedirs(directories_path)
    directory_name = f"{name.lower().replace(' ', '-')}.directory"
    with open(Path(f"{directories_path}/{directory_name}"), "w",) as directory_file:
        entry.write(directory_file, space_around_delimiters=False)


# if __name__ == "__main__":
#     logging.basicConfig(level=logging.INFO, format='%(message)s')

#     installdir = Path.cwd().resolve(strict=True)
#     appsjson = Path('apps.json').resolve(strict=True)
    
#     add_vnm_menu(installdir, 'VNM Imaging')
#     apps_from_json('lxde', installdir, appsjson)
 
