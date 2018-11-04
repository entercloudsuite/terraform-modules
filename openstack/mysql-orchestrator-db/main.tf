module "mysql" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/instance?ref=2.7"
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
    mysql_port = "${var.mysql_port}"
    mysql_master_port = "${var.mysql_master_port}"
    mysql_slaves_port = "${var.mysql_slaves_port}"
    mysql_root_name = "${var.mysql_root_name}"
    mysql_root_password = "${var.mysql_root_password}"
    mysql_admin_name = "${var.mysql_admin_name}"
    mysql_admin_password = "${var.mysql_admin_password}"
    mysql_replica_user_name = "${var.mysql_replica_user_name}"
    mysql_replica_user_password = "${var.mysql_replica_user_password}"
    mysql_user_options = "${indent(20,var.mysql_user_options)}"
    consul = "${var.consul}" 
    consul_port = "${var.consul_port}" 
    consul_datacenter = "${var.consul_datacenter}" 
    consul_encrypt = "${var.consul_encrypt}" 
    orchestrator = "${var.orchestrator}" 
    orchestrator_port = "${var.orchestrator_port}" 
    orchestrator_user = "${var.orchestrator_user}" 
    orchestrator_password = "${var.orchestrator_password}" 
    mysql_datadir = "${var.mysql_datadir}"
    pmm_server = "${var.pmm_server}"
    pmm_user = "${var.pmm_user}"
    pmm_password = "${var.pmm_password}"
    os_api = "${var.os_api}"
    os_region = "${var.os_region}"
    os_project = "${var.os_project}"
    os_project_id = "${var.os_project_id}"
    os_user = "${var.os_user}"
    os_password = "${var.os_password}"
    influxdb_url = "${var.influxdb_url}"
    influxdb_port = "${var.influxdb_port}"
    influxdb_databasename = "${var.influxdb_databasename}"
    influxdb_username = "${var.influxdb_username}"
    influxdb_password = "${var.influxdb_password}"
    restic_forget_time_day = "${var.restic_forget_time_day}"
    restic_start_backup_time = "${var.restic_start_backup_time}"
  }
}

module "mysql-volume" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/volume?ref=2.7"
  name = "${var.name}"
  size = "${var.mysql_volume_size}"
  instance = "${module.mysql.instance}"
  quantity = "${module.mysql.quantity}"
  volume_type = "${var.mysql_volume_type}"
}

resource "consul_keys" "bootstrap" {
  count = "${var.quantity > 0 ? 1 : 0}"
  key {
    path  = "mysql/master/${var.name}/custom_bootstrap"
    value = "used for bootstrap ${var.name} cluster"
    delete = true
  }
  lifecycle {
    ignore_changes = ["key"]
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
sleep 60
#screen -d -m ./cleanup.sh $PPID
./cleanup.sh
EOF
    working_dir = "${path.module}"
    environment {
      _NAME = "${var.name}"
      _NUMBER = "${count.index}"
      _HOSTNAME = "${var.name}-${count.index}"
      _CONSUL = "${var.consul}"
      _CONSUL_PORT = "${var.consul_port}"
      _CONSUL_DATACENTER = "${var.consul_datacenter}"
      _MYSQL_PORT = "${var.mysql_port}"
      OS_AUTH_URL = "${var.os_api}"
      OS_REGION_NAME = "${var.os_region}"
      OS_TENANT_NAME = "${var.os_project}"
      OS_USERNAME = "${var.os_user}"
      OS_PASSWORD = "${var.os_password}"
      _ORCHESTRATOR = "${var.orchestrator}"
      _ORCHESTRATOR_PORT = "${var.orchestrator_port}"
      _ORCHESTRATOR_USER = "${var.orchestrator_user}"
      _ORCHESTRATOR_PASSWORD = "${var.orchestrator_password}"
    }
  }
}
