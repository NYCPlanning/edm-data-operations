import yaml
import sys
import json

if __name__ == "__main__":
    file_name=sys.argv[1]
    with open(file_name, 'r') as f:
        data=yaml.load(f, Loader=yaml.SafeLoader)
    with open(file_name.replace('yml', 'json'), 'w') as f:
        json.dump(data, f, indent=4)