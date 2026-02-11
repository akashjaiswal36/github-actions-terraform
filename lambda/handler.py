import json
import boto3
import uuid

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("sre-messages")

def handler(event, context):
    body = json.loads(event.get("body", "{}"))
    message = body.get("message", "hello")

    table.put_item(
        Item={
            "id":str(uuid.uuid4()),
            "message": message
        }
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"status": "ok", "message": message})
    }