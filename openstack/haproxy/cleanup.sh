#!/bin/sh

set -x

apk update || true

while [ ! -f /usr/bin/curl ]; do
  echo "waiting for curl"
  apk add curl || true
  sleep 1
done

echo deregister node from consul
curl -sS -X PUT "http://${consul}:${consul_port}/v1/agent/force-leave/${name}-$${_NUMBER}"
curl -sS -X PUT "http://${consul}:${consul_port}/v1/catalog/deregister?dc=${consul_datacenter}" --data \{\"Datacenter\":\"${consul_datacenter}\",\"Node\":\"${name}-$${_NUMBER}\"\} > /dev/null

exit 0
