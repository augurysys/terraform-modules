variable "project" {}
variable "region" {}
variable "zone" {}
variable "network" {}

variable "subnetwork" {}
variable "riak_dc" {}

variable "cluster_size" {
  default = 5
}

variable "machine_type" {
  default = "n1-standard-4"
}
