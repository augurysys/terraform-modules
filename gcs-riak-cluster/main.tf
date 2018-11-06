resource "google_compute_address" "riak_backend" {
  project      = "${var.project}"
  name         = "${format("riak-backend-ip-%s", var.riak_dc)}"
  region       = "${var.region}"
  address_type = "INTERNAL"
  subnetwork   = "${var.subnetwork}"
}

resource "google_compute_instance" "riak" {
  count        = "${var.cluster_size}"
  project      = "${var.project}"
  name         = "${format("riak-%s-%d", var.riak_dc, count.index + 1)}"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  allow_stopping_for_update = false

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = 100
    }
  }

  scratch_disk {}
  scratch_disk {}

  network_interface {
    subnetwork = "${var.subnetwork}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    dc = "${var.riak_dc}"
  }

  metadata_startup_script = "${file("${path.module}/templates/init.sh")}"

  tags = ["riak", "${var.riak_dc}"]

  service_account {
    scopes = ["compute-ro", "storage-rw"]
  }
}

resource "google_compute_instance_group" "riak_nodes" {
  project   = "${var.project}"
  zone      = "${var.zone}"
  name      = "riak-nodes"
  instances = ["${google_compute_instance.riak.*.self_link}"]
  network   = "${var.network}"

  named_port {
    name = "pb"
    port = "8087"
  }

  named_port {
    name = "http"
    port = "8098"
  }
}

resource "google_compute_health_check" "riak_http" {
  project = "${var.project}"
  name    = "riak-http"

  timeout_sec        = 1
  check_interval_sec = 1
  healthy_threshold  = 10

  http_health_check {
    host         = "80"
    port         = "8098"
    request_path = "/ping"
  }
}

resource "google_compute_region_backend_service" "riak_pb" {
  project     = "${var.project}"
  region      = "${var.region}"
  name        = "riak-pb"
  protocol    = "TCP"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group.riak_nodes.self_link}"
  }

  health_checks = ["${google_compute_health_check.riak_http.self_link}"]
}

resource "google_compute_forwarding_rule" "riak_pb" {
  project               = "${var.project}"
  region                = "${var.region}"
  name                  = "riak-pb"
  backend_service       = "${google_compute_region_backend_service.riak_pb.self_link}"
  ports                 = ["8087"]
  ip_address            = "${google_compute_address.riak_backend.address}"
  network               = "${var.network}"
  subnetwork            = "${var.subnetwork}"
  load_balancing_scheme = "INTERNAL"
  ip_protocol           = "TCP"
}

resource "google_compute_firewall" "allow_riak_health_check" {
  project = "${var.project}"
  name    = "allow-riak-health-check"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["8087", "8098"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["riak"]
}

locals {
 cluster_instance_public_ips = "${join(",", google_compute_instance.riak.*.network_interface.0.access_config.0.assigned_nat_ip )}"
 cluster_instance_private_ips = "${join(",", google_compute_instance.riak.*.network_interface.0.address )}"
}

resource "google_compute_project_metadata_item" "cluster_instance_public_ips" {
  project = "${var.project}"
  key     = "${format("riak-cluster-public-ips-%s", var.riak_dc)}"
  value   = "${local.cluster_instance_public_ips}"
}

resource "google_compute_project_metadata_item" "cluster_instance_private_ips" {
  project = "${var.project}"
  key     = "${format("riak-cluster-private-ips-%s", var.riak_dc)}"
  value   = "${local.cluster_instance_private_ips}"
}
