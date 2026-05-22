import boto3
import requests
import os
import json
from datetime import datetime
from typing import Dict, Any

TMDB_TOKEN = os.environ.get("TMDB_TOKEN")
AWS_ACCESS_KEY_ID = os.environ.get("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.environ.get("AWS_SECRET_ACCESS_KEY")
BUCKET_NAME = os.environ.get("BUCKET_NAME")

def fetch_top_movies() -> Dict[str, Any]:

    url = "https://api.themoviedb.org/3/movie/top_rated"

    headers = {
        "accept": "application/json",
        "Authorization": f"Bearer {TMDB_TOKEN}"
    }

    response = requests.get(url, headers=headers)
    response.raise_for_status()
    
    return response.json()

def upload_to_s3(data: Dict[str, Any]) -> None:
    s3_client = boto3.client(
        's3',
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY
    )

    date_str = datetime.now().strftime("%Y-%m-%d")
    file_key = f"raw/tmdb/top_rated/{date_str}/movies.json"

    json_payload = json.dumps(data)

    s3_client.put_object(
        Bucket=BUCKET_NAME,
        Key=file_key,
        Body=json_payload,
        ContentType='application/json'
    )

if __name__ == "__main__":
    required_env_var = ["TMDB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "BUCKET_NAME"]
    missing_vars = [var for var in required_env_var if not os.environ.get(var)]

    if missing_vars:
        raise ValueError(f"Missing required environmental values : {', '.join(missing_vars)}")
            
    raw_data = fetch_top_movies()
    upload_to_s3(raw_data)
