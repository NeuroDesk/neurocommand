import requests
import json
import argparse
import os

def upload_container(container_url, container_name, token):
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
    print("Upload", r.json())

    # Update the metadata
    data = {
        'metadata': {
            'title': container_name,
            'upload_type': 'software',
            'description': container_name,
            'license': 'mit',
            'creators': [{'name': 'Neurodesk, ',
                        'affiliation': 'University of Queensland'}]
        }
    }
    r = requests.put('https://sandbox.zenodo.org/api/deposit/depositions/%s' % deposition_id,
                    params=params, data=json.dumps(data),
                    headers=headers)

    # Publish the deposition
    r = requests.post('https://sandbox.zenodo.org/api/deposit/depositions/%s/actions/publish' % deposition_id,
                      params=params )
    print("Publish", r.json())

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
    parser.add_argument("--token", type=str, required=True, help="Zenodo token")
    
    args = parser.parse_args()

    doi_url = upload_container(args.container_filepath, args.container_name, args.token)
    print(doi_url)