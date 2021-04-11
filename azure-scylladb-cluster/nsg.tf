resource "azurerm_network_security_group" "scylladb_ssh" {
    name                = "scylladbSSH"
    location            = var.resource_group.location
    resource_group_name = var.resource_group.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface_security_group_association" "scylladb_ssh" {
    count                     = var.cluster_size
    network_interface_id      = element(azurerm_network_interface.scylladb.*.id, count.index)
    network_security_group_id = azurerm_network_security_group.scylladb_ssh.id
}
