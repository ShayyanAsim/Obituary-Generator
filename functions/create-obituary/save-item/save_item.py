import boto3
import json

dynamodb_resouce = boto3.resource('dynamodb')
table = dynamodb_resouce.Table('the-last-show-30145507')


def handler(event, context):
    print(event)
    
    store_content = event['store']
    generate_content = json.loads(event['generate'])
    
    id = generate_content['id']
    name = generate_content['name']
    year_born = generate_content['year_born']
    year_died = generate_content['year_died']
    obituary = generate_content['output']
    audio_url = store_content['audio_url']
    picture_url = store_content['picture_url']
    
    content = {
        "id": id,
        "name": name,
        "year_born": year_born,
        "year_died": year_died,
        "obituary": obituary,
        "audio_url": audio_url,
        "picture_url": picture_url
        
    }
    print(content)
    try:
        table.put_item(Item=content)
        return {
            "isBase64Encoded": "false",
            'statusCode': 200,
            'body': json.dumps(content)
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps(str(e))
        }
    
    