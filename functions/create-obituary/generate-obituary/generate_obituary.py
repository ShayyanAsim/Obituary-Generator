import os
import boto3
import requests
import json
import base64

client = boto3.client('ssm')

def handler(event, context):
    client_response = client.get_parameters_by_path(
        Path='/the-last-show/',
        Recursive=True,
        WithDecryption=True,
    )
    
    name = event['name']
    year_born = event['year_born']
    year_died = event['year_died']
    id = event['id']
    api_key = client_response['Parameters'][1]['Value']
    
    prompt = f"write an obituary about a fictional character named {name} who was born on {year_born} and died on {year_died}."
    model_engine = "text-curie-001"

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }

    data = {
        "model": model_engine,
        "prompt": prompt,
        "max_tokens": 600,
        "temperature": 0.5
    }
    
    try:
        response = requests.post("https://api.openai.com/v1/completions", headers=headers, data=json.dumps(data))
        message = response.json()['choices'][0]['text']
    except:
        message = "ChatGPT had an error"
    
    response = {
        "output":message,
        "name":name,
        "year_born":year_born,
        "year_died":year_died,
        "id":id
    }
    
    return json.dumps(response)