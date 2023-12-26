resource "azurerm_resource_group" "lab" {
  name     = "${var.rg_prefix}-${var.resource_group_location}-${var.tags.environment}"
  location = var.resource_group_location
  tags     = var.tags
}

resource "azurerm_virtual_network" "lab_network" {
  name                = "${var.vnet_prefix}-${var.resource_group_location}-${var.tags.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

resource "azurerm_subnet" "jumpbox_subnet" {
  name                 = "${var.snet_prefix}-${var.resource_group_location}-${var.tags.environment}-jumpbox"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = "${var.vnet_prefix}-${var.resource_group_location}-jumpbox-nsg"
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

resource "azurerm_public_ip" "windows_vm_pip" {
  name                = "${var.vm_prefix}-${var.resource_group_location}-${var.tags.environment}-windows-pip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = var.vmname_windows
  tags                = var.tags
}

resource "azurerm_network_interface" "windows_nic" {
  name                = "${var.vm_prefix}-${var.resource_group_location}-${var.tags.environment}-windows-ip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "windows-ip"
    subnet_id                     = azurerm_subnet.jumpbox_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.7"
    public_ip_address_id          = azurerm_public_ip.windows_vm_pip.id
  }
  tags = var.tags
}

resource "azurerm_virtual_machine" "windows_vm" {
  name                  = "${var.vm_prefix}-${var.resource_group_location}-${var.tags.environment}-jumpwin"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  network_interface_ids = [azurerm_network_interface.windows_nic.id]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_prefix}-${var.resource_group_location}-windows"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.vmname_windows
    admin_username = var.ADMIN_USER
    admin_password = var.ADMIN_PSWD
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
  }
  tags = var.tags
}

resource "azurerm_public_ip" "linux_vm_pip" {
  name                = "${var.vm_prefix}-${var.resource_group_location}-${var.tags.environment}-linux-pip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = var.vmname_linux
  tags                = var.tags
}

resource "azurerm_network_interface" "linux_nic" {
  name                = "${var.vm_prefix}-${var.resource_group_location}-${var.tags.environment}-linux-ip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "linux-ip"
    subnet_id                     = azurerm_subnet.jumpbox_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.8"
    public_ip_address_id          = azurerm_public_ip.linux_vm_pip.id
  }
  tags = var.tags
}

resource "azurerm_virtual_machine" "linux_vm" {
  name                  = "${var.vm_prefix}-${var.resource_group_location}-${var.tags.environment}-jumplin"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  network_interface_ids = [azurerm_network_interface.linux_nic.id]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_prefix}-${var.resource_group_location}-linux"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.vmname_linux
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
    "vm1" = azurerm_virtual_machine.linux_vm.id
    "vm2" = azurerm_virtual_machine.windows_vm.id
  }
  virtual_machine_id = each.value
  location           = azurerm_resource_group.lab.location
  enabled            = true

  daily_recurrence_time = "0000"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled         = false
  }
}
