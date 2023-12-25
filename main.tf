resource "azurerm_resource_group" "lab" {
  name     = "${var.rg_name_prefix}-${var.resource_group_location}-${local.tags.environment}"
  location = var.resource_group_location
  tags     = local.tags
}

resource "azurerm_virtual_network" "lab_network" {
  name                = "${var.vnet_name_prefix}-${var.resource_group_location}-${local.tags.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.tags
}

resource "azurerm_subnet" "jumpbox_subnet" {
  name                 = "${var.snet_name_prefix}-${var.resource_group_location}-${local.tags.environment}"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "lab_nsg" {
  name                = "${var.vnet_name_prefix}-${var.resource_group_location}-nsg"
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

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.jumpbox_subnet.id
  network_security_group_id = azurerm_network_security_group.lab_nsg.id
}

resource "azurerm_public_ip" "windows_vm_pip" {
  name                = "${var.vm_name_prefix}-${var.resource_group_location}-${local.tags.environment}-windows-pip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"

  tags = local.tags
}

resource "azurerm_network_interface" "windows_nic" {
  name                = "${var.vm_name_prefix}-${var.resource_group_location}-${local.tags.environment}-windows-ip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "windows-ip"
    subnet_id                     = azurerm_subnet.jumpbox_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.7"
    public_ip_address_id          = azurerm_public_ip.windows_vm_pip.id
  }

  tags = local.tags
}

resource "azurerm_virtual_machine" "windows_vm" {
  name                  = "${var.vm_name_prefix}-${var.resource_group_location}-${local.tags.environment}-jumpwin"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  network_interface_ids = [azurerm_network_interface.windows_nic.id]
  vm_size               = "Standard_D2s_v3"
  // priority              = "Spot"
  // max_bid_price         = 0.5
  // eviction_policy       = "Deallocate"

  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-22h2-pro"
    version   = "latest"
  }

  storage_os_disk {
    name              = "windowsOS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "tacocat007"
    admin_username = var.ADMIN_USER
    admin_password = var.ADMIN_PSWD
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
  }

  tags = local.tags
}

resource "azurerm_public_ip" "linux_vm_pip" {
  name                = "${var.vm_name_prefix}-${var.resource_group_location}-${local.tags.environment}-linux-pip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"

  tags = local.tags
}

resource "azurerm_network_interface" "linux_nic" {
  name                = "${var.vm_name_prefix}-${var.resource_group_location}-${local.tags.environment}-linux-ip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "tacoip008"
    subnet_id                     = azurerm_subnet.jumpbox_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.8"
    public_ip_address_id          = azurerm_public_ip.linux_vm_pip.id
  }

  tags = local.tags
}

resource "azurerm_virtual_machine" "linux_vm" {
  name                  = "${var.vm_name_prefix}-${var.resource_group_location}-${local.tags.environment}-jumplin"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  network_interface_ids = [azurerm_network_interface.linux_nic.id]
  vm_size               = "Standard_D2s_v3"
  // priority              = "Spot"
  // max_bid_price         = 0.5
  // eviction_policy       = "Deallocate"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "linuxOS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "tacocat008"
    admin_username = var.ADMIN_USER
    admin_password = var.ADMIN_PSWD
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
