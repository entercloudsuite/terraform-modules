#!/bin/bash

set -e
OUTPUT=$(ovftool  -st="ISO" "$ISO_PATH" "vcloud://$VCD_URL") || $(ovftool -o -st="ISO" "$ISO_PATH" "vcloud://$VCD_URL")|| true
STAT=$(stat $ISO_PATH)
echo $STAT > iso_stat.txt
echo $OUTPUT > iso_out.txt
echo $VCD_URL > iso_url.txt

if [[ $OUTPUT == *"Media name already found"* ]]; then
	jq -r -n --arg template_name "${ISO_NAME}" --arg output  "${ISO_NAME} already exist" '{"template_name":$template_name,"output":$output}'
elif [[ $OUTPUT == *"Transfer Completed"* ]]; then
	sleep 30
	jq -r -n --arg template_name "${ISO_NAME}" --arg output  "${ISO_NAME} uploaded successfully" '{"template_name":$template_name,"output":$output}'
fi
#jq -r -n --arg template_name "Ubuntu-16.04-CloudInit" --arg output  "Ubuntu-16.04-CloudInit uploaded successfully" '{"template_name":$template_name,"output":$output}'
