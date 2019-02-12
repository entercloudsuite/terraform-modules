#!/bin/bash

set -e

OUTPUT=$(ovftool -tt=vCloud $TEMPLATE_URL "vcloud://$VCD_URL")|| true

if [[ $OUTPUT == *"vApp name already found"* ]]; then
	echo ${TEMPLATE_NAME} already exist, skip image upload
	exit 0
elif [[ $OUTPUT == *"Transfer Completed"* ]]; then
	jq -r -n --arg template_name "${TEMPLATE_NAME}" --arg output  "${TEMPLATE_NAME} uploaded successfully" '{"template_name":$template_name,"output":$output}'
fi
