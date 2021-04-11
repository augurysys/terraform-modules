
variable "resource_group" {}
variable "subnet" {}

variable "zones" {
  default = "1,2,3"
}

variable "cluster_size" {
  default = 3
}

variable "cluster_index_start" {
  default = 0
}

variable "machine_size" {
  default = "Standard_D2s_v3"
}

variable "managed_disk_size_gb" {
  default  = 40
}

variable "enable_managed_disk" {
  default = true
}

variable "scylla_dc" {}

variable "custom_seeds" {
  default = ""
}

variable "scylladb_repo" {
  default = "http://repositories.scylladb.com/scylla/repo/b71e33d0-ea15-403a-b8b8-b43e2cdcc923/centos/scylladb-4.4.repo"
}

variable "scylla_manager_repo" {
  default = "http://downloads.scylladb.com/rpm/centos/scylladb-manager-2.3.repo"
}

variable "scylladb_package" {
  default = "scylla"
}

variable "scylla_manager_agent_auth_token" {
  default = ""
}
