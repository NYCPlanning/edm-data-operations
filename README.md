# edm-data-operations
A centralized repo to handle data update/publishing between Labs and EDM

# Instructions
```bash

Usage:
./run.sh [install, show, publish, delete, diff, diff_list, list]

Commands:
   install:   Install minio and configure host -- spaces
   show:      show available versions and files e.g. ./run.sh show <dataset> --production|--staging
   publish:   publish a given dataset from a given candidate version (default candidate is "staging")
   delete:    deleting a version, by default production and staging cannot be deleted
   diff:      detecting if any file difference between production and staging. e.g. ./run.sh diff <dataset>
   diff_list: listing all dataset names that are out of sync
   list:      listing all dataset names

```