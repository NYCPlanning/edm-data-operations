from .minio import MinioClient

client = MinioClient()


def test_listDatasets():
    client.listDatasets


def test_listVersions():
    client.listVersions("commercial_overlays")


if __name__ == "__main__":
    # test_listDatasets()
    test_listVersions()
