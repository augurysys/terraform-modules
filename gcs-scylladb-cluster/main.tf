resource "google_compute_address" "scylladb" {
  count        = "${var.cluster_size}"
  project      = "${var.project}"
  name         = "${format("scylladb-ip-%s-%d", var.scylla_dc, count.index + 1)}"
  region       = "${var.region}"
  address_type = "INTERNAL"
  subnetwork   = "${var.subnetwork}"
}

resource "google_compute_disk" "scylladb-data" {
  count   = "${var.cluster_size}"
  project = "${var.project}"
  name    = "${format("scylladb-data-%s-%d", var.scylla_dc, count.index + 1)}"
  zone    = "${format("%s-%s", var.region, element(split(",", var.zones), count.index % length(split(",", var.zones))))}"
  size    = "${var.data_disk_size}"
  type    = "pd-ssd"
}

resource "google_compute_instance" "scylladb" {
  count        = "${var.cluster_size}"
  project      = "${var.project}"
  name         = "${format("scylladb-%s-%d", var.scylla_dc, count.index + 1)}"
  machine_type = "${var.machine_type}"
  zone         = "${format("%s-%s", var.region, element(split(",", var.zones), count.index % length(split(",", var.zones))))}"

  allow_stopping_for_update = false

  boot_disk {
    initialize_params {
      image = "${var.boot_disk_image}"
    }
  }

  attached_disk {
    source      = "${element(google_compute_disk.scylladb-data.*.self_link, count.index)}"
    device_name = "data"
  }

  network_interface {
    subnetwork = "${var.subnetwork}"
    address    = "${element(google_compute_address.scylladb.*.address, count.index)}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    dc = "${var.scylla_dc}"
  }

  tags = ["scylladb", "${var.scylla_dc}"]

  service_account {
    scopes = ["compute-ro"]
  }

  allow_stopping_for_update = true
}

locals {
  base_seeds = "${join(",", slice(google_compute_address.scylladb.*.address, 0, 2))}"
  seeds      = "${var.custom_seeds == "" ? local.base_seeds : join(",", list("${local.base_seeds}","${var.custom_seeds}"))}"
}

resource "google_compute_project_metadata_item" "scylladb_seeds" {
  project = "${var.project}"
  key     = "${format("scylladb-seeds-%s", var.scylla_dc)}"
  value   = "${local.seeds}"
}
