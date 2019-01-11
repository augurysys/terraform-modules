resource "google_container_node_pool" "default_np" {
  provider = "google-beta"
  project  = "${var.project_id}"

  name    = "${var.name}-k8s-node-pool"
  zone    = "${var.zone}"
  cluster = "${google_container_cluster.default.name}"

  initial_node_count = 1

  autoscaling = {
    min_node_count = "${var.autoscaling_min}"
    max_node_count = "${var.autoscaling_max}"
  }

  version = "${var.gke_version}"

  node_config = {
    machine_type    = "${var.machine_type}"
    local_ssd_count = "${var.local_ssd_count}"
    disk_size_gb    = "${var.disk_size_gb}"

    oauth_scopes = ["${var.auth_scops}"]
  }

  lifecycle {
    ignore_changes = ["initial_node_count"]
  }
}

resource "google_container_node_pool" "algo_np" {
  provider = "google-beta"
  project  = "${var.project_id}"

  name    = "${var.name}-k8s-algo-node-pool"
  zone    = "${var.zone}"
  cluster = "${google_container_cluster.default.name}"

  autoscaling = {
    min_node_count = "${var.algo_autoscaling_min}"
    max_node_count = "${var.algo_autoscaling_max}"
  }

  version = "${var.gke_version}"

  node_config = {
    preemptible  = true
    machine_type = "${var.algo_machine_type}"
    disk_size_gb = "${var.algo_disk_size_gb}"

    oauth_scopes = ["${var.auth_scops}"]

    taint = ["${var.taint}"]
  }
}

resource "google_container_cluster" "default" {
  provider           = "google-beta"
  name               = "${var.name}"
  description        = "augury's ${var.name} kubernetes cluster on gcloud"
  zone               = "${var.zone}"
  min_master_version = "${var.gke_version}"
  network            = "${var.network}"
  subnetwork         = "${var.subnetwork}"

  additional_zones = ["${var.additional_zones}"]

  private_cluster_config = {
    enable_private_nodes = true
    master_ipv4_cidr_block = "${var.master_ipv4_cidr_block}"
  }

  ip_allocation_policy = {
    cluster_ipv4_cidr_block = "${var.cluster_ipv4_cidr_block}"
    services_ipv4_cidr_block = "${var.services_ipv4_cidr_block}"
  }

  master_auth = {
    username = "${var.gke_master_username}"
    password = "${var.gke_master_password}"
  }

  master_authorized_networks_config {
    cidr_blocks = ["${var.master_authorized_networks_cidrs}"]
  }

  enable_legacy_abac = false

  lifecycle {
    ignore_changes = ["node_pool"]
  }

  node_pool {
    name = "default-pool"
  }
}
