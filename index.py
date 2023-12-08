import json

def lambda_handler(event, context):
    print('## EXECUTION OF LAMBDA')
    response = 'Hello Lambda'

    print('## EVENT')
    print(event)
    body = event['body']
    response += body

    return { 'statuscode' : 200, 'body' : json.dumps(response)}