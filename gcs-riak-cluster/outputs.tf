output "cluster_instance_public_ips" {
  value = "${local.cluster_instance_public_ips}"
}

output "cluster_instance_private_ips" {
  value = "${local.cluster_instance_private_ips}"
}

output "riak_backend_address" {
  value = "${google_compute_address.riak_backend.address}"
}
