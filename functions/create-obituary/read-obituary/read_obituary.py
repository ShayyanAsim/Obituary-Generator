import os
import boto3
import json
import base64

s3_client = boto3.client('s3')
polly_client = boto3.client('polly')

def handler(event, context):
    print(event)

    event_json = json.loads(event)
    chatgpt_text = event_json['output']
    
    response = polly_client.synthesize_speech(
        Text=chatgpt_text, 
        OutputFormat='mp3', 
        VoiceId='Joanna')
    
    audio_stream = response['AudioStream'].read()
    bucket_name = "the-last-show-s3"
    file_name = "voice.mp3"


    # Upload the image data to S3
    s3_client.put_object(Bucket=bucket_name, Key=file_name, Body=audio_stream)
