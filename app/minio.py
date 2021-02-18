from . import aws_access_key_id, aws_s3_bucket, aws_s3_endpoint, aws_secret_access_key
from minio import Minio
from minio.error import S3Error
from functools import cached_property


class MinioClient:
    def __init__(self):
        self.client = Minio(
            aws_s3_endpoint.replace("https://", ""),
            access_key=aws_access_key_id,
            secret_key=aws_secret_access_key,
        )
        self.endpoint = aws_s3_endpoint
        self.bucket = aws_s3_bucket

    @cached_property
    def listDatasets(self) -> list:
        objects = self.client.list_objects(self.bucket, prefix="datasets/")
        datasetNames = [obj.object_name.split("/")[1] for obj in objects]
        return datasetNames

    def listVersions(self, dataset: str) -> list:
        if dataset in self.listDatasets:
            objects = self.client.list_objects(
                self.bucket, prefix=f"datasets/{dataset}/"
            )
            versions = [obj.object_name.split("/")[-2] for obj in objects]
            return versions
        return []

    def listObjects(self, dataset: str) -> list:
        if dataset in self.listDatasets:
            objects = self.client.list_objects(
                self.bucket, prefix=f"datasets/{dataset}/"
            )
            versions = [obj.__dict__ for obj in objects]
            return versions
        return []

    def getLatestAndVersions(self, dataset: str):
        if dataset in self.listDatasets:
            versions = self.listVersions(dataset)
            objects = [self.getVersionObjects(dataset, v) for v in versions]
            prod_etags = list(
                map(
                    lambda x: x["etags"],
                    filter(lambda x: x["version"] == "production", objects),
                )
            )[0]
            production = ""
            for v in versions:
                objs = self.getObjectByVersion(objects, v)
                etags = list(map(lambda x: x["etags"], objs))[0]
                for etag in prod_etags:
                    if etag in etags and v not in ["staging", "production"]:
                        production = v
        else:
            versions = []
            production = []
        return {"produciton": production, "versions": versions}

    def getObjectByVersion(self, objects, version) -> list:
        return list(filter(lambda x: x["version"] == "production", objects))

    def getVersionObjects(self, dataset: str, version: str) -> dict:
        objects = self.client.list_objects(
            self.bucket, prefix=f"datasets/{dataset}/{version}/"
        )
        objects = [obj.__dict__ for obj in objects]
        etags = [obj["_etag"] for obj in objects]
        return {"version": version, "objects": objects, "etags": etags}
