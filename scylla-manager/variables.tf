variable "project" {}
variable "region" {}
variable "zone" {}
variable "subnetwork" {}

variable "boot_disk_image" {}

variable "machine_type" {
  default = "n1-standard-2"
}

variable "service_account_json" {}
variable "scylladb_seeds" {}
