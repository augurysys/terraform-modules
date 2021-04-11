resource "random_password" "password" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "azurerm_public_ip" "scylladb" {
  count               = var.cluster_size
  name                = format("scylladb-pip-%s-%d", var.scylla_dc, var.cluster_index_start + count.index + 1)
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = list(element(split(",", var.zones), (var.cluster_index_start + count.index) % length(split(",", var.zones))))
}

resource "azurerm_network_interface" "scylladb" {
  count               = var.cluster_size
  name                = format("scylladb-nic-%s-%d", var.scylla_dc, var.cluster_index_start + count.index + 1)
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(var.subnet.address_prefixes[0], count.index+5)
    public_ip_address_id          = element(azurerm_public_ip.scylladb.*.id, count.index)
  }
}

resource "azurerm_linux_virtual_machine" "scylladb" {
  count                           = var.cluster_size
  name                            = format("scylladb-%s-%d", var.scylla_dc, var.cluster_index_start + count.index + 1)
  resource_group_name             = var.resource_group.name
  location                        = var.resource_group.location
  zone                            = element(split(",", var.zones), (var.cluster_index_start + count.index) % length(split(",", var.zones)))
  size                            = var.machine_size
  admin_username                  = "azureuser"
  admin_password                  = random_password.password.result
  disable_password_authentication = false
  network_interface_ids = [
    element(azurerm_network_interface.scylladb.*.id, count.index),
  ]

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_3"
    version   = "latest"
  }

  os_disk {
    name                 = format("scylladb-os-%s-%d", var.scylla_dc, var.cluster_index_start + count.index + 1)
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  provisioner "remote-exec" {
    inline = [
      templatefile("${path.module}/conf/scylla-settings.sh", {
        ip = self.private_ip_address,
        dc = var.scylla_dc,
        scylladb_seeds = join(",", slice(azurerm_network_interface.scylladb.*.private_ip_address, 0, (var.cluster_size < 3 ? var.cluster_size : 3))),
        scylla_manager_agent_auth_token  = var.scylla_manager_agent_auth_token
      }),
    ]

    connection {
      host     = self.public_ip_address
      user     = self.admin_username
      password = self.admin_password
    }
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo yum remove -y abrt",
      "sudo yum install -y epel-release wget unzip",
      "sudo wget -O /etc/yum.repos.d/scylla.repo ${var.scylladb_repo}",
      "sudo yum install -y ${var.scylladb_package}",
      "sudo curl -o /etc/yum.repos.d/scylla-manager.repo -L ${var.scylla_manager_repo}",
      "sudo yum install -y scylla-manager-agent",
      "sudo mv /tmp/scylla-settings.sh /usr/local/bin",
      "sudo /usr/local/bin/scylla-settings.sh",
      "sudo systemctl enable scylla-manager-agent",
      "sudo systemctl start scylla-manager-agent",
      "sudo systemctl enable scylla-server.service",
    ]

    connection {
      host     = self.public_ip_address
      user     = self.admin_username
      password = self.admin_password
    }
  }
}

resource "azurerm_managed_disk" "scylladb_data" {
  count                = var.enable_managed_disk ? var.cluster_size : 0
  name                 = format("scylladb-data-%s-%d", var.scylla_dc, var.cluster_index_start + count.index + 1)
  location             = var.resource_group.location
  resource_group_name  = var.resource_group.name
  create_option        = "Empty"
  disk_size_gb         = var.managed_disk_size_gb
  storage_account_type = "StandardSSD_LRS"
  zones                = list(element(split(",", var.zones), (var.cluster_index_start + count.index) % length(split(",", var.zones))))
}

resource "azurerm_virtual_machine_data_disk_attachment" "scylladb_data" {
  count              = var.enable_managed_disk ? var.cluster_size : 0
  virtual_machine_id = element(azurerm_linux_virtual_machine.scylladb.*.id, count.index)
  managed_disk_id    = element(azurerm_managed_disk.scylladb_data.*.id, count.index)
  lun                = 0
  caching            = "None"
}
