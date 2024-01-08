import json
import boto3
import os

def lambda_handler(event, context):
    print('## EXECUTION OF LAMBDA')
    response = 'Hello Lambda'

    print('## EVENT')
    print(event)
    body = event['body']
    #body = json.loads(body)
    response += str(body)

    instance_id = os.environ['INSTANCE_ID']
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
        response_msg = f"Unsupported instance state: {instance_id}"

    print(f"Current instance state: {current_state}")

    response += response_msg

    return { 'statusCode' : 200, 'body' : json.dumps(response)}