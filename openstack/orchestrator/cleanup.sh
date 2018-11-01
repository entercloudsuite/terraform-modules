#!/bin/sh

set -e
set -x

apk update || true
apk add curl || true

while [ ! -f /usr/bin/curl ]; do
  echo "waiting for curl"
  sleep 1
done

while $( kill -0 $1 ); do
  echo "waiting terraform to finish"
  sleep 1
done

curl -sS -X PUT "http://${_CONSUL}:${_CONSUL_PORT}/v1/agent/force-leave/${_HOSTNAME}"
curl -sS -X PUT "http://${_CONSUL}:${_CONSUL_PORT}/v1/catalog/deregister?dc=${_CONSUL_DATACENTER}" --data \{\"Datacenter\":\"${_CONSUL_DATACENTER}\",\"Node\":\"${_HOSTNAME}\"\} > /dev/null

if [ ${_NUMBER} == 0 ]; then
  echo "is the last node so clean up everything"
  # remove consul keys
  curl -sS -X DELETE "http://${_CONSUL}:${_CONSUL_PORT}/v1/kv/orchestrator/master/${_NAME}?recurse=yes"
fi

exit 0
