resource "random_string" "naming_suffix" {
  length = 5
  special = false
  upper = true
  numeric = true
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  location = var.rg_location
  tags     = var.tags
}

resource "azurerm_virtual_network" "lab_network" {
  name                = "vnet-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

resource "azurerm_subnet" "jumpbox_subnet" {
  name                 = "snet-jumpbox-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = "vnet-jumpbox-nsg-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "NSGRule-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "NSGRule-SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "NSGRule-HTTP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "NSGRule-HTTPS"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "jumpbox_nsg_association" {
  subnet_id                 = azurerm_subnet.jumpbox_subnet.id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}

resource "azurerm_public_ip" "vm-jumpwin_pip" {
  name                = "vm-jumpwin-pip-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = var.vm-jumpwin_hostname
  tags                = var.tags
}

resource "azurerm_network_interface" "vm-jumpwin_nic" {
  name                = "vm-jumpwin-nic-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  // enable_accelerated_networking = true

  ip_configuration {
    name                          = "vm-jumpwin-ip"
    subnet_id                     = azurerm_subnet.jumpbox_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.7"
    public_ip_address_id          = azurerm_public_ip.vm-jumpwin_pip.id
  }
  tags = var.tags
}

resource "azurerm_virtual_machine" "vm-jumpwin" {
  name                  = "vm-jumpwin-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  network_interface_ids = [azurerm_network_interface.vm-jumpwin_nic.id]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }

  storage_os_disk {
    name              = "vm-jumpwin-disk-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.vm-jumpwin_hostname
    admin_username = var.ADMIN_USER
    admin_password = var.ADMIN_PSWD
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
  }
  tags = var.tags
}

resource "azurerm_public_ip" "vm-jumplin_pip" {
  name                = "vm-jumplin-pip-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = var.vm-jumplin_hostname
  tags                = var.tags
}

resource "azurerm_network_interface" "vm-jumplin_nic" {
  name                = "vm-jumplin-nic-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  // enable_accelerated_networking = true

  ip_configuration {
    name                          = "vm-jumplin-ip"
    subnet_id                     = azurerm_subnet.jumpbox_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.8"
    public_ip_address_id          = azurerm_public_ip.vm-jumplin_pip.id
  }
  tags = var.tags
}

resource "azurerm_virtual_machine" "vm-jumplin" {
  name                  = "vm-jumplin-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  network_interface_ids = [azurerm_network_interface.vm-jumplin_nic.id]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "vm-jumplin-disk-${var.tags.environment}-${var.rg_location}-${random_string.naming_suffix.result}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.vm-jumplin_hostname
    admin_username = var.ADMIN_USER
    admin_password = var.ADMIN_PSWD
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = var.tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_shutown" {
  for_each = {
    "vm1" = azurerm_virtual_machine.vm-jumplin.id
    "vm2" = azurerm_virtual_machine.vm-jumpwin.id
  }
  virtual_machine_id = each.value
  location           = azurerm_resource_group.lab.location
  enabled            = true

  daily_recurrence_time = "0000"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }
}
