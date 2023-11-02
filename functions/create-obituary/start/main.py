import time
import boto3
import json
import base64
from requests_toolbelt.multipart import decoder

client = boto3.client('stepfunctions')
s3_client = boto3.client('s3')

def handler(event, context):

    state_machine_arn = 'arn:aws:states:ca-central-1:294939119163:stateMachine:obituary_state_machine'

    name = event['queryStringParameters']['name']
    year_born = event['queryStringParameters']['year_born']
    year_died = event['queryStringParameters']['year_died']
    id = event['headers']['id']
    body = event['body']

    if event['isBase64Encoded']:
        body = base64.b64decode(body)
    
    content_type = event['headers']['content-type']
    data = decoder.MultipartDecoder(body, content_type)
    
    input_data = {
        "input": {
            "name": name,
            "year_born": year_born,
            "year_died": year_died,
            "id": id
        }
    }

    response = client.start_execution(
        stateMachineArn=state_machine_arn,
        input=json.dumps(input_data)
    )

    bucket_name = "the-last-show-s3"
    file_name = "picture.jpg"
    picture_s3 = data.parts[0].content


    # Upload the image data to S3
    s3_client.put_object(Bucket=bucket_name, Key=file_name, Body=picture_s3)

    execution_arn = response['executionArn']

    # Wait for the execution to complete
    while True:
        execution_result = client.describe_execution(
            executionArn=execution_arn
        )
        status = execution_result['status']
        if status == 'SUCCEEDED':
            output = json.loads(execution_result['output'])
            result = output['body'] # get the output of the last step function
            print(result)
            break
        elif status == 'FAILED':
            print("State machine execution failed")
            break
        else:
            time.sleep(1) # wait for one second before polling again


    return {
        "statusCode": output['statusCode'],
        "body": json.dumps(result)
    }