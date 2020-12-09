resource "google_container_cluster" "default" {
  provider           = google-beta
  name               = var.name
  description        = "augury's ${var.name} kubernetes cluster on gcloud"
  location           = var.zone
  min_master_version = var.gke_version
  network            = var.network
  subnetwork         = var.subnetwork
  default_max_pods_per_node = var.default_max_pods_per_node

  node_locations = var.additional_zones

  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = var.master_ipv4_cidr_block
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  master_auth {
    username = var.gke_master_username
    password = var.gke_master_password
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.master_authorized_networks_cidrs[0].cidr_block
      display_name = var.master_authorized_networks_cidrs[0].display_name
    }
  }

  enable_legacy_abac = false

  lifecycle {
    ignore_changes = [node_pool, master_auth, network, subnetwork]
  }

  node_pool {
    name = "default-pool"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "05:00"
    }
  }

  vertical_pod_autoscaling {
    enabled = true
  }
}
