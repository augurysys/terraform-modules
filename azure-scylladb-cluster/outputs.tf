output "scylladb_seeds" {
  value = join(",", slice(azurerm_network_interface.scylladb.*.private_ip_address, 0, (var.cluster_size < 3 ? var.cluster_size : 3)))
}

output "scylladb_nodes" {
  value = join(",", azurerm_network_interface.scylladb.*.private_ip_address)
}

output "scylladb_admin_password" {
  value = random_password.password.result
}
