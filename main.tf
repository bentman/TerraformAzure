resource "azurerm_resource_group" "lab" {
  name     = "rg-${var.tags.environment}-${var.rg_location}"
  location = var.rg_location
  tags     = var.tags
}

resource "azurerm_virtual_network" "lab_network" {
  name                = "vnet-${var.tags.environment}-${var.rg_location}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "jumpbox_subnet" {
  name                 = "snet-jumpbox-${var.tags.environment}-${var.rg_location}"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = "vnet-jumpbox-nsg-${var.tags.environment}-${var.rg_location}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags

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
}

resource "azurerm_subnet_network_security_group_association" "jumpbox_nsg_association" {
  subnet_id                 = azurerm_subnet.jumpbox_subnet.id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}

resource "azurerm_public_ip" "vm_jumpwin_pip" {
  name                = "vm-jumpwin-pip-${var.tags.environment}-${var.rg_location}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = var.vm_jumpwin_hostname
  tags                = var.tags
}

resource "azurerm_network_interface" "vm_jumpwin_nic" {
  name                = "vm-jumpwin-nic-${var.tags.environment}-${var.rg_location}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
  // enable_accelerated_networking = true

  ip_configuration {
    name                          = "vm-jumpwin-ip"
    subnet_id                     = azurerm_subnet.jumpbox_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.7"
    public_ip_address_id          = azurerm_public_ip.vm_jumpwin_pip.id
  }
}

resource "azurerm_windows_virtual_machine" "vm_jumpwin" {
  name                = "vm-jumpwin-${var.tags.environment}-${var.rg_location}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  computer_name       = var.vm_jumpwin_hostname
  admin_username      = var.ADMIN_USER
  admin_password      = var.ADMIN_PSWD
  tags                = var.tags

  size = "Standard_D2s_v3"
  // priority            = "Spot"
  // eviction_policy     = "Deallocate"
  // max_bid_price       = -1
  // patch_mode          = "AutomaticByPlatform"
  // hotpatching_enabled = true

  network_interface_ids = [
    azurerm_network_interface.vm_jumpwin_nic.id,
  ]

  os_disk {
    name                 = "vm-jumpwin-disk-${var.tags.environment}-${var.rg_location}"
    caching              = "ReadWrite"
    disk_size_gb         = "127"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "vm_jumplin_pip" {
  name                = "vm-jumplin-pip-${var.tags.environment}-${var.rg_location}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = var.vm_jumplin_hostname
  tags                = var.tags
}

resource "azurerm_network_interface" "vm_jumplin_nic" {
  name                = "vm-jumplin-nic-${var.tags.environment}-${var.rg_location}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
  // enable_accelerated_networking = true

  ip_configuration {
    name                          = "vm-jumplin-ip"
    subnet_id                     = azurerm_subnet.jumpbox_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.8"
    public_ip_address_id          = azurerm_public_ip.vm_jumplin_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm_jumplin" {
  name                            = "vm-jumplin-${var.tags.environment}-${var.rg_location}"
  location                        = azurerm_resource_group.lab.location
  resource_group_name             = azurerm_resource_group.lab.name
  computer_name                   = var.vm_jumplin_hostname
  admin_username                  = var.ADMIN_USER
  admin_password                  = var.ADMIN_PSWD
  disable_password_authentication = false
  tags                            = var.tags

  network_interface_ids = [
    azurerm_network_interface.vm_jumplin_nic.id,
  ]

  size = "Standard_D2s_v3"
  // priority           = "Spot"
  // eviction_policy    = "Deallocate"
  // max_bid_price      = -1
  // patch_mode         = "AutomaticByPlatform"
  // provision_vm_agent = true

  os_disk {
    name                 = "vm-jumplin-disk-${var.tags.environment}-${var.rg_location}"
    caching              = "ReadWrite"
    disk_size_gb         = "127"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_shutown" {
  for_each = {
    "vm1" = azurerm_windows_virtual_machine.vm_jumpwin.id
    "vm2" = azurerm_linux_virtual_machine.vm_jumplin.id
  }
  virtual_machine_id    = each.value
  location              = azurerm_resource_group.lab.location
  enabled               = true
  daily_recurrence_time = "0000"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }
}

/*
resource "random_string" "naming_suffix" {
  length  = 5
  special = false
  upper   = true
  numeric = true
}
// USAGE: "${random_string.naming_suffix.result}"
*/
