import json

def lambda_handler(event, context):

    response = 'Hello Lambda'

    if 'queryStringParameters' in event:
        print(event)
        query_parameters = event['queryStringParameters']
        
        # Access 'username' and 'password' from query parameters
        username = query_parameters.get('username')
        password = query_parameters.get('password')

        response += username
        response += password

        return { 'statuscode' : 200, 'body' : json.dumps(response)}
    
    else:
        
        return { 'statuscode' : 400, 'body' : json.dumps({"message": "Missing query parameters"})}