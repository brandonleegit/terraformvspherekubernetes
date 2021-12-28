##Provider

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_pass
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

##Data

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

##vSphere VMs

resource "vsphere_virtual_machine" "vm" {
  name             = "kube-3"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 4
  memory   = 4096
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "kube-3"
        domain    = "cloud.local"
      }

      network_interface {
        ipv4_address = "10.1.149.125"
        ipv4_netmask = 24
      }

      ipv4_gateway = "10.1.149.1"
    }
  }	

	
 connection {
    type     = "ssh"
    user     = "ubuntu"
    password = var.root_pass
    host     = vsphere_virtual_machine.vm.default_ip_address
 }

  
  provisioner "remote-exec" {
   inline = [
    "sleep 10",
	  "sudo sed -i 's/#DNS=/DNS=10.1.149.10/g' /etc/systemd/resolved.conf",
      "sleep 1",
      "sudo sed -i 's/#Domains=/Domains=cloud.local/g' /etc/systemd/resolved.conf",
      "sleep 1",
	  "sudo service systemd-resolved restart",
	  "sleep 1",
	  "sudo apt-get -y install debconf-utils",
	  "sleep 1",
	  "sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
      "sleep 1",      
      "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config", 
      "sudo service ssh restart",
	  "sleep 1",
      "sudo echo 'root:ubuntu' | sudo chpasswd",
      "sleep 1",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install ca-certificates curl gnupg lsb-release -y",
      "sleep 1",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "sleep 1",
      "echo deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",	  
      "sleep 1",
	  "sudo DEBIAN_FRONTEND=noninteractive apt-get update",
	  "sleep 1",
	  "sudo DEBIAN_FRONTEND=noninteractive apt-get install docker-ce docker-ce-cli containerd.io -y",
	  "sleep 1",
	  "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl -y",
	  "sleep 1",
	  "sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg",
	  "sleep 1",
	  "echo deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main | sudo tee /etc/apt/sources.list.d/kubernetes.list",
	  "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl",
	  "sleep 1",
	  "sudo DEBIAN_FRONTEND=noninteractive apt-get update",
	  "sleep 1",
	  "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y kubelet kubeadm kubectl",
	  "sleep 1",
	  "sudo swapoff -a",
	  "sudo sed -i '/ swap / s/^\\(.*\\)$/#\\1/g' /etc/fstab",
	  "sudo apt-mark hold kubelet kubeadm kubectl",
	  "sleep 10"
    ]
 }
 
 # Copies the daemon.json file to change Docker to systemd
  provisioner "file" {
    source      = "daemon.json"
    destination = "/tmp/daemon.json"
  } 
  
  provisioner "remote-exec" {
  inline = [
    "sudo mv /tmp/daemon.json /etc/docker/",
	"sudo systemctl restart docker"
	]
  }
 

 }

 ##Output

 output "ip" {
 value = vsphere_virtual_machine.vm.default_ip_address

}