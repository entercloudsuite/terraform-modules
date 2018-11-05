# ECS Module for create Mysql node and attach it to [orchestrator](https://github.com/github/orchestrator)

This module is meant to be used with orchestrator module together

## Service port

3306 is for write
3307 is for read-only

## Example

```
module "orchestrator" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/orchestrator?ref=2.7"
  external = "true"
  name = "orchestrator"
  network_name = "${var.network_name}"
  keypair = "${var.keypair_name}"
  sec_group = ["${module.internal.sg_id}"]
  image = "ecs-orchestrator 1.1.2"
  orchestrator_password = "supersecretorchestrator"
  orchestrator_http_auth_password = "supersecretorchestrator"
  orchestrator_raft_nodes = "[ 'orchestrator-0.node.automium.consul', 'orchestrator-1.node.automium.consul', 'orchestrator-2.node.automium.consul' ]"
  consul = "consul.service.automium.consul"
  consul_datacenter = "automium"
  consul_encrypt = "supersecretconsul"
}

module "mysql-orchestrator" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/mysql-orchestrator-db?ref=2.7"
  quantity = 4
  network_name = "${var.network_name}"
  keypair = "${var.keypair_name}"
  sec_group = ["${module.pluto-internal.sg_id}","${module.enter_1.sg_id}","${module.enter_2.sg_id}"]
  name = "mysql-orchestrator"
  image = "ecs-mysql 1.1.1"
  flavor = "e3standard.x4"
  mysql_admin_password = "supersecretadmin"
  mysql_replica_user_password = "supersecretreplica"
  mysql_volume_size = "20"
  mysql_volume_type = "SSD-Standard"
  orchestrator = "orchestrator.service.automium.consul"
  orchestrator_password = "supersecretorchestrator"
  consul = "consul.service.automium.consul"
  consul_datacenter = "automium"
  consul_encrypt = "supersecretconsul"
  pmm_server = "pmm.service.automium.consul"
  pmm_user = "admin"
  pmm_password = "supersecretpmm"
  influxdb_url = "influxdb.automium.eu"
  influxdb_port = "10000"
  influxdb_databasename = "backup"
  influxdb_username = "write"
  influxdb_password = "supersecretinfluxdb"
  os_api = "https://api.it-mil1.entercloudsuite.com/v2.0/"
  os_region = "nl-ams1"
  os_project = "pippo@pluto.eu"
  os_project_id = "d51f5317474f40c6bd2905ccf3zc7e80"
  os_user = "pippo@pluto.eu"
  os_password = "supersecretos"
}
```

## Rebuild a broken node
```
NODE_NUMBER=0
MODULE_LOCAL_NAME=mysql-orchestrator
./terraform taint -module=${MODULE_LOCAL_NAME}.mysql "consul_catalog_entry.service.${NODE_NUMBER}"
./terraform taint -module=${MODULE_LOCAL_NAME}.mysql "openstack_compute_instance_v2.cluster.${NODE_NUMBER}"
./terraform taint -module=${MODULE_LOCAL_NAME}.mysql "openstack_networking_port_v2.port_local.${NODE_NUMBER}"
./terraform taint -module=${MODULE_LOCAL_NAME}.mysql-volume "openstack_blockstorage_volume_v2.volume.${NODE_NUMBER}"
./terraform taint -module=${MODULE_LOCAL_NAME}.mysql-volume "openstack_compute_volume_attach_v2.va.${NODE_NUMBER}"
```
if you have a floating ip you need also
```
./terraform taint -module=${MODULE_LOCAL_NAME}.mysql "openstack_compute_floatingip_associate_v2.external_ip.${NODE_NUMBER}"
./terraform taint -module=${MODULE_LOCAL_NAME}.mysql "openstack_networking_floatingip_v2.ips.${NODE_NUMBER}"
```
and apply the changes
```
./terrafrom apply
```
