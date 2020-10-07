"""Generate the menu items."""
import configparser
import json
import os
from pathlib import Path
import re
from typing import Text
import xml.etree.ElementTree as et
from xml.dom import minidom
import logging

def add_menu(installdir: Path, name: Text) -> None:
    """Add a submenu to 'VNM' menu.

    Parameters
    ----------
    name : Text
        The name of the submenu.
    """
    logging.info(f"Adding submenu for '{name}'")
    # Generate `.directory` file
    entry = configparser.ConfigParser()
    entry.optionxform = str
    entry["Desktop Entry"] = {
        "Name": name,
        "Comment": name,
        "Icon": installdir/f"icons/{name}.png",
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
    dir_el.text = "vnm/"+directory_name
    include_el = et.SubElement(sub_el, "Include")
    and_el = et.SubElement(include_el, "And")
    cat_el = et.SubElement(and_el, "Category")
    cat_el.text = name.replace(" ", "-")
    xmlstr = minidom.parseString(et.tostring(root)).toprettyxml(indent="\t")
    with open(menu_path, "w") as f:
        f.write('<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"\n ')
        f.write('"http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">\n\n')
        f.write(xmlstr[xmlstr.find("?>") + 3 :])
    os.chmod(menu_path, 0o644)


def add_app(
    installdir: Path,
    name: Text,
    version: Text,
    category: Text,
    exec: Text = "",
    terminal: bool = True,
) -> None:
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
    entry = configparser.ConfigParser()
    entry.optionxform = str

    if exec:
        # assumes that executable name is before the dash and after the dash the normal container name and version
        container_name = name.split("-")[1]
        exec_name = name.split("-")[0] + " " + name.split("-")[1].split(" ")[1]
    else: 
        container_name = name
        exec_name = name

    entry["Desktop Entry"] = {
        "Name": exec_name,
        "GenericName": exec_name,
        "Comment": name + " " + version,
        "Exec": "bash " + str(Path(Path.cwd(),"fetch_and_run.sh"))  + " " + container_name + " " + version  + " " + exec,
        "Icon": Path(Path.cwd(),"icons",f"{name.split()[0]}.png"),
        "Type": "Application",
        "Categories": category,
        "Terminal": str(terminal).lower(),
    }
    applications_path = installdir/"applications"
    if not os.path.exists(applications_path):
        os.makedirs(applications_path)
    desktop_path = Path(
        f"{applications_path}/vnm-{name.lower().replace(' ', '-')}.desktop"
    )
    with open(desktop_path, "w",) as desktop_file:
        entry.write(desktop_file, space_around_delimiters=False)
    os.chmod(desktop_path, 0o644)


def apps_from_json(installdir: Path, appsjson: Path) -> None:
    # Read applications file
    with open(appsjson, "r") as json_file:
        menu_entries = json.load(json_file)

    for menu_name, menu_data in menu_entries.items():
        # Add submenu
        add_menu(installdir, menu_name)
        for app_name, app_data in menu_data.get("apps", {}).items():
            # Add application
            add_app(installdir, app_name, category=menu_name.replace(" ", "-"), **app_data)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format='%(message)s')

    installdir = Path.cwd().resolve(strict=True)
    appsjson = Path('apps.json').resolve(strict=True)
    apps_from_json(installdir, appsjson)