import os
from dotenv import load_dotenv

# Load environmental variables
load_dotenv()

# Configure aws s3 connection info
aws_access_key_id = os.environ["AWS_ACCESS_KEY_ID"]
aws_secret_access_key = os.environ["AWS_SECRET_ACCESS_KEY"]
aws_s3_endpoint = os.environ["AWS_S3_ENDPOINT"]
aws_s3_bucket = os.environ["AWS_S3_BUCKET"]
