#!/bin/sh

set -x

apk update || true

while [ ! -f /usr/bin/curl ]; do
  echo "waiting for curl"
  apk add curl || true
  sleep 1
done

#while $( kill -0 $1 ); do
#  echo "waiting terraform to finish"
#  sleep 1
#done

echo deregister node from consul
curl -sS -X PUT "http://${_CONSUL}:${_CONSUL_PORT}/v1/agent/force-leave/${_HOSTNAME}"
curl -sS -X PUT "http://${_CONSUL}:${_CONSUL_PORT}/v1/catalog/deregister?dc=${_CONSUL_DATACENTER}" --data \{\"Datacenter\":\"${_CONSUL_DATACENTER}\",\"Node\":\"${_HOSTNAME}\"\} > /dev/null

exit 0
