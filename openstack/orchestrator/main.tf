module "orchestrator" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/instance?ref=feature"
  name = "${var.name}"
  image = "${var.image}"
  quantity = "${var.quantity}"
  external = "${var.external}"
  region = "${var.region}"
  flavor = "${var.flavor}"
  network_name = "${var.network_name}"
  sec_group = "${var.sec_group}"
  discovery = "${var.discovery}"
  keypair = "${var.keypair}"
  userdata = "${data.template_file.cloud-config.*.rendered}"
  tags = {
    "server_group" = "${var.name}"
  }
}

data "template_file" "cloud-config" {
  template = "${file("${path.module}/cloud-config.yml")}"
  count = "${var.quantity}"
  vars {
    name = "${var.name}"
    number = "${count.index}"
    hostname = "${var.name}-${count.index}"
    orchestrator_port = "${var.orchestrator_port}" 
    orchestrator_service_port = "${var.orchestrator_service_port}" 
    orchestrator_user = "${var.orchestrator_user}" 
    orchestrator_password = "${var.orchestrator_password}" 
    orchestrator_http_auth_user = "${var.orchestrator_http_auth_user}"
    orchestrator_http_auth_password = "${var.orchestrator_http_auth_password}"
    orchestrator_authentication_method = "${var.orchestrator_authentication_method}"
    orchestrator_raft_enabled = "${var.orchestrator_raft_enabled}" 
    orchestrator_raft_data_dir = "${var.orchestrator_raft_data_dir}" 
    orchestrator_raft_default_port = "${var.orchestrator_raft_default_port}" 
    orchestrator_raft_nodes = "${var.orchestrator_raft_nodes}" 
    consul = "${var.consul}" 
    consul_port = "${var.consul_port}" 
    consul_datacenter = "${var.consul_datacenter}" 
    consul_encrypt = "${var.consul_encrypt}" 
  }
}

resource "null_resource" "cleanup" {
  count = "${var.quantity}"
  provisioner "local-exec" {
    when = "destroy"
    command= <<EOF
chmod +x cleanup.sh
apk update || true
apk add screen || true
while [ ! -f /usr/bin/screen ]; do echo "waiting for screen"; sleep 1; done
screen -d -m ./cleanup.sh $PPID
EOF
    working_dir = "${path.module}"
    environment {
      _NAME = "${var.name}"
      _NUMBER = "${count.index}"
      _HOSTNAME = "${var.name}-${count.index}"
      _CONSUL = "${var.consul}" 
      _CONSUL_PORT = "${var.consul_port}" 
      _CONSUL_DATACENTER = "${var.consul_datacenter}" 
    }
  }
}
