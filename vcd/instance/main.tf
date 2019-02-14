resource "vcd_vapp" "vApp" {
 name = "vApp_${var.name}"
 network_name = "${var.network_name}"
 power_on = "false"
}

resource "vcd_vapp_vm" "instance" {
 vapp_name = "vApp_${var.name}"
 count = "${var.quantity}"
 name = "${var.name}-${count.index}"
 catalog_name  = "${var.catalog}"
 template_name = "${data.external.image_sync.result.template_name}"
 memory = "${var.memory}"
 cpus = "${var.cpus}"
 network_name = "${var.network_name}"
 provisioner "local-exec" {
  when = "destroy"
  environment {
    VCD_AUTH = "${var.vcd_username}@${var.vcd_org}:${var.vcd_password}"
    VCD_URL = "${var.vcd_url}"
    VM_NAME = "${var.name}-${count.index}"
    ACTION = "powerOn"
  }
    interpreter = ["bash", "-c"]
    command = "${path.module}/power_ctl.sh && sleep 30"
 }
 depends_on = ["vcd_vapp.vApp"]
 power_on = "false"
}
resource "vcd_inserted_media" "ISO" {
 count = "${var.quantity}"
 catalog = "${var.catalog}"
 name = "${var.name}-${count.index}-user-data.iso"
 vapp_name = "vApp_${var.name}"
 vm_name = "${var.name}-${count.index}"
 provisioner "local-exec" {
  when = "destroy"
  environment {
    VCD_AUTH = "${var.vcd_username}@${var.vcd_org}:${var.vcd_password}"
    VCD_URL = "${var.vcd_url}"
    VM_NAME = "${var.name}-${count.index}"
    ACTION = "powerOff"
  }
    interpreter = ["bash", "-c"]
    command = "${path.module}/power_ctl.sh && sleep 30"
 }
 depends_on = ["vcd_vapp_vm.instance"]
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

resource "null_resource" "cloud_init_iso_clean" {
  count = "${var.quantity}"
  depends_on = ["data.external.iso_upload"]
  provisioner "local-exec" {
    command = "rm ${path.module}/${var.name}-${count.index}-user-data.iso"
  }
}
data "external" "iso_upload" {
  count = "${var.quantity}"
  depends_on = ["null_resource.cloud_init_iso"]
  program = [
    "/bin/bash",
    "-c",
    <<EOF
export VCD_URL='${var.vcd_username}:${var.vcd_password}@${var.vcd_server}/cloud?org=${var.vcd_org}&vdc=${var.vcd_vdc}&media=${var.name}-${count.index}-user-data.iso&catalog=${var.catalog}'
export ISO_PATH='${path.module}/${var.name}-${count.index}-user-data.iso'
bash ${path.module}/iso_upload.sh
EOF
  ]
}
data "external" "power_on" {
  count = "${var.quantity}"
  depends_on = ["vcd_inserted_media.ISO"]
  program = [
    "/bin/bash",
    "-c",
    <<EOF
export VCD_AUTH='${var.vcd_username}@${var.vcd_org}:${var.vcd_password}'
export VCD_URL='${var.vcd_url}'
export VM_NAME='${var.name}-${count.index}'
export ACTION='powerOn'
bash ${path.module}/power_ctl.sh
EOF
  ]
}

data "external" "image_sync" {
  program = [
    "/bin/bash",
    "-c",
    <<EOF
export VCD_URL='${var.vcd_username}:${var.vcd_password}@${var.vcd_server}/cloud?org=${var.vcd_org}&vdc=${var.vcd_vdc}&vappTemplate=${var.template}&catalog=${var.catalog}'
export TEMPLATE_NAME=${var.template}
export TEMPLATE_URL=https://swift.entercloudsuite.com/v1/KEY_1a68c22a99cd4e558054ede2c878929d/automium-catalog-images/vsphere/${var.template}.ova
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
