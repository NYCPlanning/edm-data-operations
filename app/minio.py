from . import aws_access_key_id, aws_s3_bucket, aws_s3_endpoint, aws_secret_access_key
from minio import Minio
from minio.error import S3Error

class MinioClient:
    def __init__(self):
        self.client = Minio(
            aws_s3_endpoint.replace("https://", ""),
            access_key=aws_access_key_id,
            secret_key=aws_secret_access_key,
        )
        self.endpoint = aws_s3_endpoint
        self.bucket = aws_s3_bucket
    
    @property
    def list_datasets(self):
        objects = self.client.list_objects(self.bucket, prefix="/datasets/")
        for obj in objects:
            print(obj)