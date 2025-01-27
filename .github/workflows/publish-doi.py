import requests
import json
import argparse

def post(container_filepath, container_name, token):
    headers = {"Content-Type": "application/json"}
    params = {'access_token': token}
    r = requests.post('https://sandbox.zenodo.org/api/deposit/depositions',
                    params=params,
                    json={},
                    headers=headers)
    deposition_id = r.json()['id']
    bucket_url = r.json()["links"]["bucket"]

    # New API 
    path = "./%s" % container_filepath

    
    # The target URL is a combination of the bucket link with the desired filename
    # seperated by a slash.
    with open(path, "rb") as fp:
        r = requests.put(
            "%s/%s" % (bucket_url, container_filepath),
            data=fp,
            params=params,
        )

    data = {
        'metadata': {
            'title': container_name,
            'upload_type': 'software',
            'description': container_name,
            'creators': [{'name': 'Neurodesk, ',
                        'affiliation': 'University of Queensland'}]
        }
    }
    r = requests.put('https://sandbox.zenodo.org/api/deposit/depositions/%s' % deposition_id,
                    params={'access_token': token}, data=json.dumps(data),
                    headers=headers)

    # r = requests.post('https://sandbox.zenodo.org/api/deposit/depositions/%s/actions/publish' % deposition_id,
    #                   params={'access_token': token} )
    # print(r.status_code)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog="Upload container to Zenodo",
    )
    
    parser.add_argument("--container_filepath", type=str, required=True, help="Container file to upload to Zenodo")
    parser.add_argument("--container_name", type=str, required=True, help="Container name")
    parser.add_argument("--token", type=str, required=True, help="Zenodo token")
    
    args = parser.parse_args()

    post(args.container_filepath, args.container_name, args.token)