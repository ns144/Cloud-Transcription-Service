import json
import base64
import boto3
import os
import logging

client = boto3.client('autoscaling')

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

    total_duration = params.get('total_duration')
    total_files = params.get('total_files')
    logging_triggering_user_id = params.get('logging_triggering_user_id')
    logging_triggering_transcript_id = params.get(
        'logging_triggering_transcript_id')

    logger.info(f"Started by {logging_triggering_user_id}.{logging_triggering_transcript_id}")

    logger.info(f"Total duration: {total_duration}")
    logger.info(f"Total files: {total_files}")

    group = os.environ['ASG_NAME']

    current_desired_capacity = get_current_desired_capacity(group)

    if total_files > 2 and total_duration > 900:
        desired_capacity = 2
    else:
        desired_capacity = 1

    # Only allow to scale up. Scaling down is handled by stop_lambda.
    if desired_capacity > current_desired_capacity:
        response = client.update_auto_scaling_group(AutoScalingGroupName=group, DesiredCapacity=desired_capacity)
        logger.info(f"EC2 Upscaling. Response: {response}")
        return {'statusCode': 200, 'body': json.dumps(response)}

    logger.info("Auto Scaling Group already at desired capacity.")
    return {'statusCode': 200, 'body': json.dumps({"response": "Auto Scaling Group already at desired capacity"})}


def get_current_desired_capacity(group_name):
    response = client.describe_auto_scaling_groups(
        AutoScalingGroupNames=[group_name],
    )
    return response["AutoScalingGroups"][0]["DesiredCapacity"]
