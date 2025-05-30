import requests
import argparse
import json
from pathlib import Path

def get_apps():
    """
    Get the list of apps from app.json file
    """
    with open(Path("./neurodesk/apps.json"), "r") as json_file:
        menu_entries = json.load(json_file)

    app_list = []
    for menu_name, menu_data in menu_entries.items():
        for app_name, app_data in menu_data.get("apps", {}).items():
            if app_data.get("exec") == "":
                IMAGENAME_VERSION = app_name.split(" ")[0] + "_" + app_name.split(" ")[-1] + "_" + app_data.get("version")
                app_list.append(IMAGENAME_VERSION)
    return app_list

def fetch_zenodo_dois(zenodo_token):
    """
    Fetch the list of DOIs from Zenodo
    """
    page = 1
    params = {
        "access_token": zenodo_token,
        "status": "published",
        "page": 1,
        "size": 100,
    }
    url = "https://sandbox.zenodo.org/api/deposit/depositions"
    response = requests.get(url, params=params)
    if response.status_code != 200:
        raise Exception(f"Failed to fetch DOIs: {response.status_code} {response.text}")
    dois = response.json()

    while 'next' in response.links:
        page += 1
        params = {
            "access_token": zenodo_token,
            "status": "published",
            "page": page,
            "size": 100,
        }
        # print(f"Fetching next page of packages from Github", response.links['next']['url'], params, page)
        response=requests.get(url, params=params)

        if response.status_code != 200:
            raise Exception(f"Failed to fetch DOIs: {response.status_code} {response.text}")
        # print(f"Fetched {len(response.json())} packages from Github", response.json())
        dois.extend(response.json())

    doi_list = []
    for doi in dois:
        doi_list.append(doi['title'])
    return doi_list

def find_missing_zenodo_dois(gh_packages, zenodo_dois):
    """
    Compare the list of DOIs from Zenodo with the list of packages from Github
    """
    gh_packages = set(gh_packages)
    zenodo_dois = set(zenodo_dois)
    # print(f"Found {len(gh_packages.intersection(zenodo_dois))} common items")

    unpublished_apps = [item for item in gh_packages if item not in zenodo_dois]
    batch_size = 50
    batches = [{"apps": unpublished_apps[i:i + batch_size]} for i in range(0, len(unpublished_apps), batch_size)]
    return batches

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog="Get Github Packages with Tags or Published DOIs from Zenodo",
    )

    parser.add_argument("--zenodo_token", type=str, required=True, help="Zenodo token")
    args = parser.parse_args()

    gh_packages = get_apps()
    zenodo_dois = fetch_zenodo_dois(args.zenodo_token)
    batches = find_missing_zenodo_dois(gh_packages, zenodo_dois)
    print(batches)