import json
import base64
import boto3
import os
import time

def lambda_handler(event, context):
    print('## EXECUTION OF LAMBDA')
    response = ''

    print('## EVENT')
    print(event)
    try:
        body = event['body']
        params = event['queryStringParameters']
        key = params['key']
    except:
        response = "No API Key provided"
        return { 'statusCode' : 401, 'body' : json.dumps(response)}

    instance_id = os.environ['INSTANCE_ID']
    secret = os.environ['SECRET']
    secret = base64.b64decode(secret)
    secret = json.loads(secret)
    transcription_key = secret['TRANSCRIPTION_SERVICE_API_KEY']
    
    if key != transcription_key:
        response = "Incorrect API Key provided"
        return { 'statusCode' : 401, 'body' : json.dumps(response)}
    
    
    ec2 = boto3.client('ec2')

    # Check the current state of the instance
    instance = ec2.describe_instances(InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]
    current_state = instance['State']['Name']

    response_msg = ""

    # Start or stop the instance based on its current state
    if current_state == 'stopped':
        print(f"Starting instance: {instance_id}")
        ec2.start_instances(InstanceIds=[instance_id])
        print(f"Instance started: {instance_id}")
        response_msg = f"Instance started: {instance_id}"
    elif current_state == 'running':
        #print(f"Stopping instance: {instance_id}")
        #ec2.stop_instances(InstanceIds=[instance_id])
        #print(f"Instance stopped: {instance_id}")
        response_msg = f"Instance already running: {instance_id}"
    else:
        print(f"Unsupported instance state: {current_state}")
        # This happens at the startup and shutdown of an Instance
        unsupported = True
        while unsupported:
            time.sleep(5)
            # Check the current state of the instance
            instance = ec2.describe_instances(InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]
            current_state = instance['State']['Name']
            if current_state == 'stopped':
                print(f"Starting instance: {instance_id}")
                ec2.start_instances(InstanceIds=[instance_id])
                print(f"Instance started: {instance_id}")
                response_msg = f"Instance started: {instance_id}"
                break
            elif current_state == 'running':
                response_msg = f"Instance already running: {instance_id}"
                break
            else:
                print("Unsupported instance state. Trying again")
            

    print(f"Current instance state: {current_state}")

    response += response_msg

    return { 'statusCode' : 200, 'body' : json.dumps(response)}