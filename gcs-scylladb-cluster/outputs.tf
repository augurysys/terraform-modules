output "scylladb_seeds" {
  value = join(",", slice(google_compute_address.scylladb.*.address, 0, (var.cluster_size < 3 ? var.cluster_size - 1 : 2)))
}

output "scylladb_addresses" {
  value = google_compute_address.scylladb.*.address
}
