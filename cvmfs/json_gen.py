import json
import argparse

def process_text_to_json(application, doi_url):
    my_dict = {}
    val = []

    with open("log.txt") as f:
        for line in f:
            line = line.split()
            
            # Find the matching application and update its DOI
            if application in line[0]:
                val.append({"application": line[0], "categories": ' '.join(line[1:]).replace("categories:","").rstrip(',').split(","), "doi": doi_url})
            else:
                val.append({"application": line[0], "categories": ' '.join(line[1:]).replace("categories:","").rstrip(',').split(",")})
        my_dict['list'] = val
        
    with open('applist.json', 'w') as fp:     
        json.dump(my_dict, fp, sort_keys=True, indent=4)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog="Update DOI for app list",
    )
    parser.add_argument("--application", type=str, required=True, help="Application name and version")
    parser.add_argument("--doi_url", type=str, required=True, help="DOI URL")
    
    args = parser.parse_args()

    process_text_to_json(args.application, args.doi_url)
