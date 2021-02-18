from flask import Flask, jsonify
from .minio import MinioClient

app = Flask(__name__)
client = MinioClient()


@app.route("/")
def listDatasets():
    return jsonify(client.listDatasets)


@app.route("/versions/<name>")
def listVersions(name: str):
    versions = client.getLatestAndVersions(name)
    return jsonify(versions)


if __name__ == "__main__":
    app.run(debug=True)
