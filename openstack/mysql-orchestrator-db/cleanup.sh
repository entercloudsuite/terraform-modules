#!/bin/sh

set -x

export OS_AUTH_URL="${os_api}"
export OS_REGION_NAME="${os_region}"
export OS_TENANT_NAME="${os_project}"
export OS_USERNAME="${os_user}"
export OS_PASSWORD="${os_password}"

apk update || true

while [ ! -f /usr/bin/curl ]; do
  echo "waiting for curl"
  apk add curl || true
  sleep 1
done

while [ ! -f /usr/bin/pip ]; do
  echo "waiting for pip"
  apk add --update py-pip || true
  sleep 1
done

until pip freeze | grep python-swiftclient==3.6.0; do
  echo "waiting for swift"
  pip install --upgrade pip || true
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
  pip install --upgrade pip || true
  pip install python-openstackclient==3.17.0 || true
  sleep 1
done

echo deregister node from consul
curl -sS -X PUT "http://${consul}:${consul_port}/v1/agent/force-leave/${name}-$${_NUMBER}"
curl -sS -X PUT "http://${consul}:${consul_port}/v1/catalog/deregister?dc=${consul_datacenter}" --data \{\"Datacenter\":\"${consul_datacenter}\",\"Node\":\"${name}-$${_NUMBER}\"\}

echo deregister node from orchestrator
curl -sS http://${orchestrator_user}:${orchestrator_password}@${orchestrator}:${orchestrator_port}/api/forget/${name}-$${_NUMBER}.node.${consul_datacenter}.consul/${mysql_port}

if [ ${quantity} == 0 ]; then
  echo "is the last node so clean up everything"
  # remove consul keys
  curl -sS -X DELETE "http://${consul}:${consul_port}/v1/kv/mysql/master/${name}?recurse=yes"
  # rename swift container backup
  if [ $${_NUMBER} == 0 ]; then
    TOKEN=$(openstack token issue -f json | jq .id)
    CONTAINER=mysql_${name}
    swift --os-auth-token $${TOKEN} list $${CONTAINER} | parallel --no-notice --jobs 8 "swift --os-auth-token $${TOKEN} copy --destination /$${CONTAINER}$(date +%s)/{} $${CONTAINER} {}"
    swift --os-auth-token $${TOKEN} delete --object-threads 8 --container-threads 8 $${CONTAINER}
  fi
fi

exit 0
