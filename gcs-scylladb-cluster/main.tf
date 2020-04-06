resource "google_compute_address" "scylladb" {
  count        = var.cluster_size
  project      = var.project
  name         = format("scylladb-ip-%s-%d", var.scylla_dc, var.cluster_index_start + count.index + 1)
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = var.subnetwork
}

resource "google_compute_disk" "scylladb-data" {
  count   = var.local_ssds == 0 ? var.cluster_size : 0
  project = var.project
  name    = format("scylladb-data-%s-%d", var.scylla_dc, var.cluster_index_start + count.index + 1)
  zone    = format("%s-%s", var.region, element(split(",", var.zones), (var.cluster_index_start + count.index) % length(split(",", var.zones))))
  size    = var.data_disk_size
  type    = "pd-ssd"
}

resource "google_compute_instance" "scylladb" {
  count        = var.cluster_size
  project      = var.project
  name         = format("scylladb-%s-%d", var.scylla_dc, var.cluster_index_start + count.index + 1)
  machine_type = var.machine_type
  zone         = format("%s-%s", var.region, element(split(",", var.zones), (var.cluster_index_start + count.index) % length(split(",", var.zones))))

  allow_stopping_for_update = var.local_ssds == 0 ? true : false

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
    }
  }

  dynamic "attached_disk" {
    for_each = var.local_ssds == 0 ? [1] : []
    content {
      source      = element(google_compute_disk.scylladb-data.*.self_link, count.index)
      device_name = "data"
    }
  }

  dynamic "scratch_disk" {
    for_each = var.local_ssds == 0 ? [] : range(var.local_ssds)
    content {
      interface = "NVME"
    }
  }

  network_interface {
    network_ip = element(google_compute_address.scylladb.*.address, count.index)
    subnetwork = var.subnetwork

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    dc         = var.scylla_dc
    local_ssds = var.local_ssds
  }

  tags = ["scylladb", var.scylla_dc]

  service_account {
    scopes = ["compute-ro"]
  }
}
