data "template_file" "init" {
  template = "${file("${path.module}/templates/init.tpl")}"

  vars = {
    service_account_json = "${var.service_account_json}"
    scylladb_node        = "${element(split(",",var.scylladb_seeds),0)}"
  }
}

resource "google_compute_address" "scylladb_manager" {
  project      = "${var.project}"
  name         = "scylladb-manager"
  region       = "${var.region}"
  address_type = "INTERNAL"
  subnetwork   = "${var.subnetwork}"
}

resource "google_compute_instance" "scylladb_manager" {
  project      = "${var.project}"
  name         = "scylladb-manager"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      image = "${var.boot_disk_image}"
    }
  }

  network_interface {
    network_ip = "${google_compute_address.scylladb_manager.address}"
    subnetwork = "${var.subnetwork}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = "${data.template_file.init.rendered }"

  service_account {
    scopes = ["compute-ro"]
  }

  allow_stopping_for_update = true
}
