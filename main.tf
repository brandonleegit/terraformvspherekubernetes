

module "kubemaster" {
  source = "./kube_master"
  vsphere_server = var.vsphere_server
  vsphere_user = var.vsphere_user
  vsphere_pass = var.vsphere_pass
  vsphere_datacenter = var.vsphere_datacenter
  vsphere_network = var.vsphere_network
  vsphere_template = var.vsphere_template
  vsphere_cluster = var.vsphere_cluster
  vsphere_datastore = var.vsphere_datastore
  root_pass = var.root_pass
  

}

module "kube_worker1" {
  source = "./kube_worker1"
  vsphere_server = var.vsphere_server
  vsphere_user = var.vsphere_user
  vsphere_pass = var.vsphere_pass
  vsphere_datacenter = var.vsphere_datacenter
  vsphere_network = var.vsphere_network
  vsphere_template = var.vsphere_template
  vsphere_cluster = var.vsphere_cluster
  vsphere_datastore = var.vsphere_datastore
  root_pass = var.root_pass

}

module "kube_worker2" {
  source = "./kube_worker2"
  vsphere_server = var.vsphere_server
  vsphere_user = var.vsphere_user
  vsphere_pass = var.vsphere_pass
  vsphere_datacenter = var.vsphere_datacenter
  vsphere_network = var.vsphere_network
  vsphere_template = var.vsphere_template
  vsphere_cluster = var.vsphere_cluster
  vsphere_datastore = var.vsphere_datastore
  root_pass = var.root_pass

}









