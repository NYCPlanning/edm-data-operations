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

# Publishing workflow
If a change is detected between the datasets in the `staging` and `production` folders an issue is automatically opened. 
![Screen Shot 2021-04-21 at 10 33 44 AM](https://user-images.githubusercontent.com/5611960/115571551-1a48d000-a28d-11eb-815a-0cbb70c92f9a.png)

If the files pass your review, comment [publish] under this issue.
![Screen Shot 2021-04-21 at 10 35 49 AM](https://user-images.githubusercontent.com/5611960/115571816-5b40e480-a28d-11eb-8062-c0e36babf295.png)

This triggers a GitHub Action to move the staging files to production.

Staging applications point to datasets in the `staging` folder, which are synced with the general Carto instance, while production applcations point to datasets in the `production` folder, which are synced with the Planning Labs Carto instance.
