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

variable "gke_version" {
  default = "1.10.2-gke.3"
}

variable "gke_master_username" {
  default = ""
}

variable "gke_master_password" {
  default = ""
}

variable "autoscaling_mix" {
  default = 1
}

variable "autoscaling_max" {
  default = 1
}

variable "machine_type" {
  default = "n1-standard-2"
}

variable "local_ssd_count" {
  default = 1
}

variable "disk_size_gb" {
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
