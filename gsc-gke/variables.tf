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

variable "gke_version" {}

variable "gke_master_username" {
  default = ""
}

variable "gke_master_password" {
  default = ""
}

variable "autoscaling_min" {
  default = 0
}

variable "autoscaling_max" {
  default = 1
}

variable "algo_node_pool_enabled" {
  default = "true"
}

variable "algo_autoscaling_min" {
  default = 0
}

variable "algo_autoscaling_max" {
  default = 1
}

variable "machine_type" {
  default = "n1-standard-2"
}

variable "algo_machine_type" {
  default = "n1-highmem-2"
}

variable "local_ssd_count" {
  default = 1
}

variable "disk_size_gb" {
  default = 300
}

variable "algo_disk_size_gb" {
  default = 300
}

variable "auth_scops" {
  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]
}

variable "taint" {
  type = "list"

  default = [
    {
      key    = "cloud.google.com/gke-preemptible"
      value  = "true"
      effect = "NO_SCHEDULE"
    },
  ]
}

variable "master_ipv4_cidr_block" {}
variable "cluster_ipv4_cidr_block" {}
variable "services_ipv4_cidr_block" {}

variable "master_authorized_networks_cidrs" {
  type    = "list"
  default = []
}
