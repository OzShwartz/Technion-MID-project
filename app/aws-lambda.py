import boto3
import logging
from botocore.exceptions import ClientError

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

def send_sns_notification(file_name, topic_arn):
    """
    Sends an SNS notification about a file uploaded to S3.

    :param file_name: The name of the file uploaded to S3.
    :param topic_arn: The SNS Topic ARN to send the notification to.
    """
    subject = "File Uploaded to S3!"
    message = (
        f"An image file '{file_name}' was uploaded to your S3 bucket.\n"
        "This notification was sent via SNS."
    )
    
    # Create a new SNS client
    sns = boto3.client('sns')

    try:
        # Send the notification
        response = sns.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject=subject
        )
        logger.info(f"Notification sent successfully. Message ID: {response['MessageId']}")
    except ClientError as e:
        logger.error(f"Failed to send notification: {e.response['Error']['Message']}")

def lambda_handler(event, context):
    """
    Lambda function to handle S3 event and send SNS notification on file upload.

    :param event: The event data passed by Lambda (contains S3 bucket and file details).
    :param context: The context in which the function is called.
    """
    try:
        # Extract the bucket name and file name from the event
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        file_name = event['Records'][0]['s3']['object']['key']

        # Log the event details
        logger.info(f"File '{file_name}' uploaded to bucket '{bucket_name}'")

        # Send an SNS notification
        topic_arn = "arn:aws:sns:us-east-1:535998477374:UploadTriggerNotification" ###
        send_sns_notification(file_name, topic_arn)

    except KeyError as e:
        logger.error(f"KeyError - missing expected key: {str(e)}")
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")

