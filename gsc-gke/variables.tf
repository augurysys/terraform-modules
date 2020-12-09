variable "name" {}
variable "project_id" {}
variable "network" {}

variable "subnetwork" {
  default = "default"
}

variable "zone" {
  default = "us-east1-b"
}

variable "additional_zones" {
  default = [
    "us-east1-c",
    "us-east1-d",
  ]
}

variable "default_max_pods_per_node" {
  default = 110
}

variable "gke_version" {}

variable "gke_master_username" {
  default = ""
}

variable "gke_master_password" {
  default = ""
}

variable "master_ipv4_cidr_block" {}
variable "cluster_ipv4_cidr_block" {}
variable "services_ipv4_cidr_block" {}

variable "master_authorized_networks_cidrs" {
  type    = list
  default = []
}
