#!/bin/bash

set -e
OUTPUT=$(ovftool -st="ISO" $ISO_PATH "vcloud://$VCD_USERNAME:$VCD_PASSWORD@$VCD_CLOUD_URL?org=$VCD_ORG&vdc=$VCD_VDC&media=$ISO_NAME&catalog=$VCD_CATALOG")|| true
#to check
if [[ $OUTPUT == *"vApp name already found"* ]]; then
	echo ${TEMPLATE_NAME} already exist, skip image upload
	exit 0
elif [[ $OUTPUT == *"Transfer Completed"* ]]; then
	jq -r -n --arg template_name "${TEMPLATE_NAME}" --arg output  "${TEMPLATE_NAME} uploaded successfully" '{"template_name":$template_name,"output":$output}'
fi
