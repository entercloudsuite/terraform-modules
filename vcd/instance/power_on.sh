#!/bin/bash
TOKEN=$(curl -I -s -i -k -H "Accept:application/*+xml;version=1.5" -u '$VCD_AUTH' -X POST $VCD_URL/sessions |grep  auth |awk {'print $2'} |sed -s 's/\r$//')
VAPP_URL=$(curl -s -i -k -H "Accept:application/*+xml;version=1.5" -H "x-vcloud-authorization: $TOKEN" -X GET  "$VCD_URL/query?type=vApp" |grep -i $VAPP_NAME|awk {'print $13'} |sed -e 's/href="//' |sed -s 's/"//')
POWERON="/power/action/powerOn"
curl -i -k -H "Accept:application/*+xml;version=1.5" -H "x-vcloud-authorization: $TOKEN" -X POST "$VAPP_URL""$POWERON"
