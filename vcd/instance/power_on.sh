#!/bin/bash
TOKEN=$(curl -I -s -i -k -H "Accept:application/*+xml;version=1.5" -u $VCD_AUTH -X POST $VCD_URL/sessions |grep  auth |awk {'print $2'} |sed -s 's/\r$//')
echo $TOKEN > vcd_token.txt
VM_URL=$(curl -s -i -k -H "Accept:application/*+xml;version=1.5" -H "x-vcloud-authorization: $TOKEN" -X GET  "$VCD_URL/query?type=vm" |grep name=\"$VM_NAME\"  |grep -o "href.*" | sed 's/\s.*$//' |sed -e 's/href="//' |sed -s 's/"//')
echo $VM_URL > vcd_poweron_url.txt
POWERON=$(curl -s -i -k -H "Accept:application/*+xml;version=1.5" -H "x-vcloud-authorization: $TOKEN" -X POST $VM_URL"/power/action/powerOn")
echo $POWERON > vcd_poweron.txt
jq -r -n --arg vm_name "${VM_NAME}" --arg output  "${VM_NAME} powered on" '{"vm_name":$vm_name,"output":$output}'
