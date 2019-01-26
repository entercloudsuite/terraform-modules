#!/bin/bash

set -e

OUTPUT=$({

EXISTING_TEMPLATE="$(govc find -type m -name "${TEMPLATE_NAME}" | head -n 1)"
if [ -n "${EXISTING_TEMPLATE}" ]; then
  echo ${TEMPLATE_NAME} already exist, skip image upload
  exit 0
fi

govc import.ova -dc="${TEMPLATE_DC}" -ds="${TEMPLATE_DS}" -pool="${TEMPLATE_POOL}" -name="${TEMPLATE_NAME}" "${TEMPLATE_URL}"
govc vm.markastemplate -dc="${TEMPLATE_DC}" "${TEMPLATE_NAME}"

})

OUTPUT=$(echo $OUTPUT | cut -c 1-20)
jq -r -n --arg template_name "${TEMPLATE_NAME}" --arg output "${OUTPUT}" '{"template_name":$template_name,"output":$output}'
