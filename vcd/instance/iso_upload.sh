#!/bin/bash

set -e
OUTPUT=$(ovftool -st="ISO" $ISO_PATH "vcloud://$VCD_USERNAME:$VCD_PASSWORD@$VCD_CLOUD_URL?org=$VCD_ORG&vdc=$VCD_VDC&media=$ISO_NAME&catalog=$VCD_CATALOG")|| true
echo $OUTPUT > iso_out.txt
if [[ $OUTPUT == *"Media name already found"* ]]; then
	echo ${ISO_NAME} already exist, skip image upload
	exit 0
elif [[ $OUTPUT == *"Transfer Completed"* ]]; then
	jq -r -n --arg template_name "${ISO_NAME}" --arg output  "${ISO_NAME} uploaded successfully" '{"template_name":$template_name,"output":$output}'
fi
#jq -r -n --arg template_name "Ubuntu-16.04-CloudInit" --arg output  "Ubuntu-16.04-CloudInit uploaded successfully" '{"template_name":$template_name,"output":$output}'
