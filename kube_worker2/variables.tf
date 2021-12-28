variable "vsphere_server" {}

variable "vsphere_user" {}

variable "vsphere_pass" {
  sensitive = true
}

variable "root_pass" {}

variable "vsphere_datacenter" {}

variable "vsphere_network" {}

variable "vsphere_template" {}

variable "vsphere_cluster" {}

variable "vsphere_datastore" {}