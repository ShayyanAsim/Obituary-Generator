import time
import hashlib
import boto3
import json
import requests

client = boto3.client("ssm")
s3_client = boto3.client("s3")


def handler(event, context):
    # Get the audio and image
    bucket_name = "the-last-show-s3"

    picture_name = "picture.jpg"
    audio_name = "voice.mp3"

    # Download the object from S3
    picture_response = s3_client.get_object(Bucket=bucket_name, Key=picture_name)
    audio_response = s3_client.get_object(Bucket=bucket_name, Key=audio_name)

    # Read the binary data of the downloaded object
    picture = picture_response["Body"].read()
    audio = audio_response["Body"].read()

    # Get cloudinary info
    client_response = client.get_parameters_by_path(
        Path="/the-last-show/",
        Recursive=True,
        WithDecryption=True,
    )
    ssm = client_response["Parameters"][0]["Value"]
    ssm_split = ssm.split(",")
    cloud_name = ssm_split[0]
    api_key = ssm_split[1]
    api_key_secret = ssm_split[2]
    print(api_key_secret, api_key)

    timestamp = str(int(time.time()))

    public_id_audio = json.loads(event["generate"])["name"] + "_audio"
    to_sign = "public_id=" + public_id_audio + "&timestamp=" + timestamp + api_key_secret
    signature_audio = hashlib.sha1(to_sign.encode()).hexdigest()

    public_id_picture = json.loads(event["generate"])["name"] + "_picture"
    to_sign = "public_id=" + public_id_picture + "&timestamp=" + timestamp + api_key_secret
    signature_picture = hashlib.sha1(to_sign.encode()).hexdigest()

    # Upload the audio and picture to cloudinary
    audio_response = requests.post(
        f"https://api.cloudinary.com/v1_1/{cloud_name}/raw/upload",
        files={"file": audio},
        data={
            "api_key": api_key,
            "public_id": public_id_audio,
            "timestamp": timestamp,
            "signature": signature_audio,
        }
    )
    picture_response = requests.post(
        f"https://api.cloudinary.com/v1_1/{cloud_name}/image/upload",
        files={"file": picture},
        data={
            "api_key": api_key,
            "public_id": public_id_picture,
            "timestamp": timestamp,
            "signature": signature_picture,
        }
    )

    audio_url = json.loads(audio_response.text)["url"]
    picture_url = json.loads(picture_response.text)["url"]
    picture_url = picture_url.replace(
        "image/upload", "image/upload/e_art:zorrro,e_grayscale"
    )

    output = {"audio_url": audio_url, "picture_url": picture_url}

    return output
