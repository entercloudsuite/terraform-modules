#!/bin/sh

set -x

apk update || true

while [ ! -f /usr/bin/curl ]; do
  echo "waiting for curl"
  apk add curl || true
  sleep 1
done

while [ ! -f /usr/bin/pip ]; do
  echo "waiting for pip"
  apk add py-pip || true
  sleep 1
done

until pip freeze | grep python-swiftclient==3.6.0; do
  echo "waiting for swift"
  pip install python-swiftclient==3.6.0 || true
  sleep 1
done

while [ ! -f /usr/bin/parallel ]; do
  echo "waiting for parallel"
  apk add parallel
  sleep 1
done

while [ ! -f /usr/bin/jq ]; do
  echo "waiting for jq"
  apk add jq
  sleep 1
done

while [ ! -f /usr/bin/openstack ]; do
  echo "waiting for openstack"
  apk add gcc python-dev musl-dev linux-headers libffi-dev openssl-dev
  pip install python-openstackclient==3.15.0 || true
  sleep 1
done

#while $( kill -0 $1 ); do
#  echo "waiting terraform to finish"
#  sleep 1
#done

echo deregister node from consul
curl -sS -X PUT "http://${_CONSUL}:${_CONSUL_PORT}/v1/agent/force-leave/${_HOSTNAME}"
curl -sS -X PUT "http://${_CONSUL}:${_CONSUL_PORT}/v1/catalog/deregister?dc=${_CONSUL_DATACENTER}" --data \{\"Datacenter\":\"${_CONSUL_DATACENTER}\",\"Node\":\"${_HOSTNAME}\"\}

echo deregister node from orchestrator
curl -sS http://${_ORCHESTRATOR_USER}:${_ORCHESTRATOR_PASSWORD}@${_ORCHESTRATOR}:${_ORCHESTRATOR_PORT}/api/forget/${_HOSTNAME}.node.${_CONSUL_DATACENTER}.consul/${_MYSQL_PORT}

if [ ${_NUMBER} == 0 ]; then
  echo "is the last node so clean up everything"
  # remove consul keys
  curl -sS -X DELETE "http://${_CONSUL}:${_CONSUL_PORT}/v1/kv/mysql/master/${_NAME}?recurse=yes"
  # rename swift container backup
  TOKEN=$(openstack token issue -f json | jq .id)
  CONTAINER=mysql_${_NAME}
  swift --os-auth-token ${TOKEN} list ${CONTAINER} | parallel --no-notice --jobs 8 "swift --os-auth-token ${TOKEN} copy --destination /${CONTAINER}$(date +%s)/{} ${CONTAINER} {}"
  swift --os-auth-token ${TOKEN} delete --object-threads 8 --container-threads 8 ${CONTAINER}
fi

exit 0
