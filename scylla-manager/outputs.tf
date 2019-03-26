output "scylla_manager_ip" {
  value = "${google_compute_address.scylladb_manager.address}"
}
