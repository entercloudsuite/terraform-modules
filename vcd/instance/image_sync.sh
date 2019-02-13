#!/bin/bash

set -e

OUTPUT=$(ovftool -tt=vCloud $TEMPLATE_URL "vcloud://$VCD_URL")|| true
echo $OUTPUT > out.txt
echo $VCD_URL > url.txt

if [[ $OUTPUT == *"vApp name already found"* ]]; then
	jq -r -n --arg template_name "${TEMPLATE_NAME}" --arg output  "${TEMPLATE_NAME} already exist" '{"template_name":$template_name,"output":$output}'
elif [[ $OUTPUT == *"Transfer Completed"* ]]; then
	jq -r -n --arg template_name "${TEMPLATE_NAME}" --arg output  "${TEMPLATE_NAME} uploaded successfully" '{"template_name":$template_name,"output":$output}'
fi
#jq -r -n --arg template_name "Ubuntu-16.04-CloudInit" --arg output  "Ubuntu-16.04-CloudInit uploaded successfully" '{"template_name":$template_name,"output":$output}'
