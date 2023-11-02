# add your get-obituaries function here
import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("the-last-show-30145507")

def handler(event, context):
    table_name = 'the-last-show-30145507'
    
    # Set the scan parameters
    try:
        table_response = table.scan()
        if table_response["Count"] == 0:
            response = {
                "statusCode":200,
                "body": json.dumps({
                    "message": "No obituaries found",
                    "data":[]
                })
            }
            print(response)
            return response
            
        print(table_response)
        response = {
            "statusCode":200,
            "body": json.dumps({
                "message": "Obituaries found",
                "data":table_response['Items']
            })
        }
        print(response)
        return response
                
    except Exception as e:
        response={
            "statusCode":404,
            "body":json.dumps({
                "message":str(e)
            })
            
        }
        return response