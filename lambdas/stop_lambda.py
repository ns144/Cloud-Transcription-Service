import json
import base64
import boto3
import os
import logging
import requests

# Create logger
logger = logging.getLogger()
logger.setLevel("INFO")

# Custom logging format to only print log level and message
handler = logging.StreamHandler()
formatter = logging.Formatter('[%(levelname)s] %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


def lambda_handler(event, context):
    try:
        params = event['queryStringParameters']
        key = params['key']
        instance_id = params['ec2_id']

    except KeyError:
        response = "No API Key provided"
        return {'statusCode': 401, 'body': json.dumps(response)}

    secret = os.environ['SECRET']
    secret = base64.b64decode(secret)
    secret = json.loads(secret)
    transcription_key = secret['TRANSCRIPTION_SERVICE_API_KEY']

    if key != transcription_key:
        response = "Incorrect API Key provided"
        return {'statusCode': 401, 'body': json.dumps(response)}

    client = boto3.client('autoscaling')

    response = client.terminate_instance_in_auto_scaling_group(
        InstanceId=instance_id,
        ShouldDecrementDesiredCapacity=True)

    logger.info(f"EC2 Shutdown. Response: {response}")

    # Run health check when scaling down to zero
    response = client.describe_auto_scaling_groups(
        AutoScalingGroupNames=[os.environ['ASG_NAME']])
    desired_capacity = response['AutoScalingGroups'][0]['DesiredCapacity']
    if desired_capacity == 0:
        logger.info("Scaled down to zero. Running health check.")
        requests.get(f"https://ton-texter.de/api/transcript/health-check?key={transcription_key}")
        if response.status_code != 200:
            logger.warning("Health check is not reachable.")

    return {'statusCode': 200, 'body': json.dumps(response)}
