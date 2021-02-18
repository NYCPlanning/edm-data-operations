from flask import Flask
from .minio import MinioClient

app = Flask(__name__)
client = MinioClient()

@app.route('/')
def hello_world():
    return client.list_datasets
