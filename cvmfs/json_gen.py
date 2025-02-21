import json

def process_text_to_json():
    my_dict = {}
    val = []

    with open("log.txt") as f:
        for line in f:
            line = line.split()
            val.append({"application": line[0], "categories": ' '.join(line[1:]).replace("categories:","").rstrip(',').split(",")})
        my_dict['list'] = val
        
    with open('applist.json', 'w') as fp:     
        json.dump(my_dict, fp, sort_keys=True, indent=4)

if __name__ == '__main__':
    process_text_to_json()