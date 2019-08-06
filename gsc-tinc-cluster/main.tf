resource "google_compute_address" "tinc" {
  count   = var.cluster_size
  project = var.project_id
  name    = format("tinc-%s-%d", var.name, count.index + 1)
  region  = var.region
}

resource "google_compute_instance" "tinc" {
  count        = var.cluster_size
  project      = var.project_id
  name         = format("tinc-%s-%d", var.name, count.index + 1)
  machine_type = "f1-micro"
  zone         = format("%s-%s", var.region, element(split(",", var.zones), count.index % length(split(",", var.zones))))

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = var.subnetwork

    access_config {
      nat_ip = element(google_compute_address.tinc.*.address, count.index)
    }
  }

  service_account {
    scopes = ["compute-ro", "storage-ro"]
  }

  tags = ["tinc"]

  metadata_startup_script = <<EOMD
#!/bin/sh
apt-get update && apt-get install -y tinc
EOMD
}
