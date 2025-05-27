import requests
import json
import argparse
import os
import yaml

def get_license(container_name, gh_token):
    """
    Get the license from copyright field in YAML file in the container.
    """
    recipe_name = container_name.split("/")[-1]
    # Get yaml recipe using github API
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": "Bearer " + gh_token,
        "X-GitHub-Api-Version": "2022-11-28",
    }
    # Get the recipe name from the container name
    recipe_name = container_name.split("/")[-1]
    url = f" https://api.github.com/repos/NeuroDesk/neurocontainers/contents/recipes/{recipe_name}/build.yaml"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        # Get the license from the recipe
        download_url = response.json()["download_url"]
        download_url_response = requests.get(download_url)
        download_url_response.raise_for_status()
        content = download_url_response.content.decode("utf-8")
        tinyrange_config = yaml.safe_load(content)
        # print("Tinyrange config", tinyrange_config['copyright'])
        copyrights = tinyrange_config.get('copyright', {})
        print("Copyright field", copyrights)
        if not copyrights:
            print("No copyright field found in the recipe")
            return None, None
        for copyright in copyrights:
            license = copyright.get('license', None)
            license_url = copyright.get('url', None)
        return license, license_url
    else:
        print("Failed to get recipe", response.status_code, response.text)
        return ""

def get_license_id(license_name):
    # Get the license ID from Zenodo
    headers = {"Content-Type": "application/json"}
    response = requests.get('https://sandbox.zenodo.org/api/licenses/',
                            headers=headers)
    
    if response.status_code == 200:
        licenses = response.json()['hits']['hits']
        for license in licenses:
            if license['id'].lower() == license_name.lower():
                return license['id']
    else:
        print("Failed to get licenses", response.status_code, response.text)
    return None, None

def upload_container(container_url, container_name, token, license, license_url):
    headers = {"Content-Type": "application/json"}
    params = {'access_token': token}

    # Create a new deposition
    r = requests.post('https://sandbox.zenodo.org/api/deposit/depositions',
                    params=params,
                    json={},
                    headers=headers)
    deposition_id = r.json()['id']
    bucket_url = r.json()["links"]["bucket"]

    # Upload the simg container to bucket in the created deposition
    # The target URL is a combination of the bucket link with the desired filename
    # seperated by a slash.
    # print("Uploading container to Zenodo...", container_url)
    
    with requests.get(container_url, stream=True) as response:
        response.raise_for_status()  # Ensure the request was successful
        r = requests.put(
            f"{bucket_url}/{os.path.basename(container_url)}", # bucket is a flat structure, can't include subfolders in it
            data=response.content,  # Stream the file directly
            params=params,
        )

    # Update the metadata
    data = {
        'metadata': {
            'title': container_name,
            'upload_type': 'software',
            'description': container_name,
            'license': license,
            'creators': [{'name': 'Neurodesk',
                        'affiliation': 'University of Queensland'}]
        }
    }
    if license:
        data['metadata']['license'] = license
        print("Updating metadata", data)
        r = requests.put('https://sandbox.zenodo.org/api/deposit/depositions/%s' % deposition_id,
                        params=params, data=json.dumps(data),
                        headers=headers)
    else:
        r = requests.put('https://sandbox.zenodo.org/api/deposit/depositions/%s' % deposition_id,
                params=params, data=json.dumps(data),
                headers=headers)
    with requests.get(container_url, stream=True) as response:
        response.raise_for_status()  # Ensure the request was successful
        r = requests.put(
            f"{bucket_url}/{os.path.basename(container_url)}", # bucket is a flat structure, can't include subfolders in it
            data=response.content,  # Stream the file directly
            params=params,
        )
    

    # Publish the deposition
    r = requests.post('https://sandbox.zenodo.org/api/deposit/depositions/%s/actions/publish' % deposition_id,
                      params=params )
    # print("Publish", r.json())

    # Get the DOI from the deposition
    r = requests.get('https://sandbox.zenodo.org/api/deposit/depositions/%s' % deposition_id,
            params=params,
            headers=headers)
    doi_url = r.json()["doi_url"]
    return doi_url

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog="Upload container to Zenodo",
    )
    
    parser.add_argument("--container_filepath", type=str, required=True, help="Container file to upload to Zenodo")
    parser.add_argument("--container_name", type=str, required=True, help="Container name")
    parser.add_argument("--zenodo_token", type=str, required=True, help="Zenodo token")
    parser.add_argument("--gh_token", type=str, required=True, help="GitHub token to access the recipe")
    args = parser.parse_args()

    license, license_url = get_license(args.container_name, args.token)
    doi_url = upload_container(args.container_filepath, args.container_name, args.token, license, license_url)
    print(doi_url)