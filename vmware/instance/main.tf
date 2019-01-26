data "vsphere_datacenter" "datacenter" {
  name = "${var.datacenter}"
}

data "vsphere_datastore_cluster" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_datastore" "iso_datastore" {
  name          = "${var.iso_datastore}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_network" "vm-network" {
  name          = "${var.network_name}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${data.external.image_sync.result.template_name}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.cluster}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

resource "vsphere_virtual_machine" "instance" {
  name             = "${var.name}-${count.index}"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_cluster_id = "${data.vsphere_datastore_cluster.datastore.id}"
  count = "${var.quantity}"

  num_cpus = "${var.cpus}"
  memory   = "${var.memory}"
  memory_reservation = "${var.memory_reservation}"

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id = "${data.vsphere_network.vm-network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label = "disk-os"
    size  = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  } 

  cdrom {
    datastore_id = "${data.vsphere_datastore.iso_datastore.id}"
    path         = "${var.folder}/${var.name}-${count.index}-user-data.iso"
  }

  lifecycle {
    ignore_changes = ["cdrom.0.path","clone.0.template_uuid","disk.0.io_share_count","disk.0.key","disk.0.uuid","disk.0.datastore_id","disk.0.device_address","disk.0.path"]
  }

  depends_on = ["vsphere_file.cloud_init_iso_upload","null_resource.postdestroy"]
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "cluster_vm_anti_affinity_rule" {
  count               = "${var.quantity > 0 ? 1 : 0}"
  name                = "${var.name}-terraform--cluster-vm-anti-affinity-rule"
  compute_cluster_id  = "${data.vsphere_compute_cluster.cluster.id}"
  virtual_machine_ids = ["${vsphere_virtual_machine.instance.*.id}"]
}

resource "consul_catalog_entry" "service_local" {
  count = "${var.discovery ? var.quantity : 0}"
  address = "${vsphere_virtual_machine.instance.*.default_ip_address[count.index]}"
  node    = "${var.name}-${count.index}"

  service = {
    address = "${vsphere_virtual_machine.instance.*.default_ip_address[count.index]}"
    id      = "${var.name}-${count.index}"
    name    = "${var.name}"
    port    = "${var.discovery_port}"
    tags    = ["${count.index}"]
  }
}

data "template_file" "meta-data" {
  count = "${var.quantity}"
  template = "${file("${path.module}/meta-data.tmpl")}"
  vars = {
    name = "${var.name}"
    hostname = "${var.name}-${count.index}"
    keypair = "${var.keypair}"
  }
}

resource "null_resource" "cloud_init_iso" {
  count = "${var.quantity}"
  provisioner "local-exec" {
    command = <<EOF
mkdir ${path.module}/${var.name}-${count.index}-iso
cat <<'EOS' > ${path.module}/${var.name}-${count.index}-iso/user-data
${element(var.userdata,count.index)}
EOS
cat <<'EOS' > ${path.module}/${var.name}-${count.index}-iso/meta-data
${data.template_file.meta-data.*.rendered[count.index]} 
EOS
genisoimage -output ${path.module}/${var.name}-${count.index}-user-data.iso -volid cidata -joliet -rock ${path.module}/${var.name}-${count.index}-iso/user-data ${path.module}/${var.name}-${count.index}-iso/meta-data
rm -rf ${path.module}/${var.name}-${count.index}-iso
EOF
  }
}

resource "vsphere_file" "cloud_init_iso_upload" {
  count = "${var.quantity}"
  depends_on = ["null_resource.cloud_init_iso"]
  datacenter       = "${var.datacenter}"
  datastore        = "${var.iso_datastore}"
  create_directories = "true"
  source_file      = "${path.module}/${var.name}-${count.index}-user-data.iso"
  destination_file = "${var.folder}/${var.name}-${count.index}-user-data.iso"
}

resource "null_resource" "cloud_init_iso_clean" {
  count = "${var.quantity}"
  depends_on = ["vsphere_file.cloud_init_iso_upload"]
  provisioner "local-exec" {
    command = "rm ${path.module}/${var.name}-${count.index}-user-data.iso"
  }
}

data "external" "image_sync" {
  program = [
    "/bin/bash",
    "-c",
    <<EOF
export GOVC_URL='${var.user}:${var.password}@${var.vsphere_server}'
export GOVC_INSECURE=1
export TEMPLATE_NAME=${var.template}
export TEMPLATE_DC=${var.datacenter}
export TEMPLATE_DS=${var.template_datastore}
export TEMPLATE_URL=https://swift.entercloudsuite.com/v1/KEY_1a68c22a99cd4e558054ede2c878929d/automium-catalog-images/vsphere/${var.template}.ova
export TEMPLATE_POOL=${data.vsphere_compute_cluster.cluster.resource_pool_id}
export TEMPLATE_FOLDER=${var.folder}
bash ${path.module}/image_sync.sh
EOF
  ]
}

output "image_sync_message" {
  value = "${data.external.image_sync.result.output}"
}

resource "null_resource" "postdestroy" {
  count = "${var.quantity}"
  provisioner "local-exec" {
    when = "destroy"
    command = "${var.postdestroy}"
    environment {
      _NUMBER = "${count.index}"
    }
  }
}
