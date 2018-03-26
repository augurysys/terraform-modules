output "scylladb_seeds" {
  value = "${join(",", slice(google_compute_address.scylladb.*.address, 0, 2))}"
}
