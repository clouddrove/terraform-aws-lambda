import boto3
import os
import logging
import json
import requests
import collections
import datetime
import sys
import pprint

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec = boto3.client("ec2")

SLACK_CHANNEL           = os.environ['SLACK_CHANNEL']
SLACK_WEBHOOK           = os.environ['SLACK_WEBHOOK']
ICON_EMOJI = ':cloudtrail:'
USERNAME   = 'CloudTrail Bot'

def lambda_handler(event, context):
    message = json.loads(event["Records"][0]["Sns"]["Message"])
    payload = create_slack_payload({
        'Message': message
    })
    post_to_slack(payload)

def create_slack_payload(json_dict, color='#FF0000', reason='Alarm Event.'):
    logger.info('Creating slack payload from the following json: {}'.format(json_dict))
    payload ={
        "attachments": [
           {
                "fallback": reason,
                "color": color,
                "title": reason,
                "fields": [
                    {
                        "title": "Action",
                        "value": "Config Rules Notification",
                        "short": True
                    },
                    {
                        "title": "Message",
                        "value": '```\n{}\n```'.format(json.dumps(json_dict['Message'], indent=4)),
                        "short": False
                    }
                ],
                "footer": "CloudDrove",
                "footer_icon": "https://clouddrove.com/media/images/favicon.ico",
            }
        ],
        'channel': SLACK_CHANNEL,
        'username': USERNAME,
        'icon_emoji': ICON_EMOJI
    }

    return payload


def post_to_slack(payload):
    logger.info('POST-ing payload: {}'.format(json.dumps(payload,indent=4)))

    try:
        req = requests.post(SLACK_WEBHOOK, data=str(payload), timeout=3)
        logger.info("Message posted to {} using {}".format(payload['channel'], SLACK_WEBHOOK))
    except requests.exceptions.Timeout as e:
        fatal("Server connection failed: {}".format(e))
    except requests.exceptions.RequestException as e:
        fatal("Request failed: {}".format(e))

    if req.status_code != 200:
        fatal(
            "Non 200 status code: {}\nResponse Headers: {}\nResponse Text: {}".format(
                req.status_code,
                req.headers,
                json.dumps(req.text, indent=4)
            ),
            code=255
        )

