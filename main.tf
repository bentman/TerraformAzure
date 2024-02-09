resource "azurerm_resource_group" "lab" {
  location = var.rg_location
  name     = "rg-${var.tags.environment}-${var.rg_location}"
  tags     = var.tags
}

resource "azurerm_virtual_network" "lab_network" {
  location            = azurerm_resource_group.lab.location
  name                = "vnet-${var.tags.environment}-${var.rg_location}"
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
  location            = azurerm_resource_group.lab.location
  name                = "vnet-jumpbox-nsg-${var.tags.environment}-${var.rg_location}"
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
  location            = azurerm_resource_group.lab.location
  name                = "vm-jumpwin-pip-${var.tags.environment}-${var.rg_location}"
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = var.vm_jumpwin_hostname
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "vm_jumpwin_nic" {
  location            = azurerm_resource_group.lab.location
  name                = "vm-jumpwin-nic-${var.tags.environment}-${var.rg_location}"
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
  location            = azurerm_resource_group.lab.location
  name                = "vm-jumpwin-${var.tags.environment}-${var.rg_location}"
  resource_group_name = azurerm_resource_group.lab.name
  computer_name       = var.vm_jumpwin_hostname
  admin_username      = var.ADMIN_USER
  admin_password      = var.ADMIN_PSWD
  tags                = var.tags

  size = "Standard_D2s_v3"

  network_interface_ids = [
    azurerm_network_interface.vm_jumpwin_nic.id,
  ]

  os_disk {
    name                 = "vm-jumpwin-osdisk-${var.tags.environment}-${var.rg_location}"
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
  location            = azurerm_resource_group.lab.location
  name                = "vm-jumplin-pip-${var.tags.environment}-${var.rg_location}"
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  domain_name_label   = var.vm_jumplin_hostname
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "vm_jumplin_nic" {
  location            = azurerm_resource_group.lab.location
  name                = "vm-jumplin-nic-${var.tags.environment}-${var.rg_location}"
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
  location                        = azurerm_resource_group.lab.location
  name                            = "vm-jumplin-${var.tags.environment}-${var.rg_location}"
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

  os_disk {
    name                 = "vm-jumplin-osdisk-${var.tags.environment}-${var.rg_location}"
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

##### SQL Server #####
locals {
  generated_password = random_password.sql_password.result
}

resource "random_password" "sql_password" {
  length           = 16
  special          = true
  override_special = "!@#$()-_=+[]{}"
}

resource "azurerm_network_interface" "vm_sql_nic" {
  location            = azurerm_resource_group.lab.location
  name                = "vm-sql-nic-${var.tags.environment}-${var.rg_location}"
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
  // enable_accelerated_networking = true

  ip_configuration {
    name                          = "vm-sql-ip"
    subnet_id                     = azurerm_subnet.jumpbox_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.20"
  }
}

resource "azurerm_windows_virtual_machine" "vm_sql" {
  location            = azurerm_resource_group.lab.location
  name                = "vm-sql-${var.tags.environment}-${var.rg_location}"
  resource_group_name = azurerm_resource_group.lab.name
  computer_name       = var.vm_sql_hostname
  admin_username      = var.ADMIN_USER
  admin_password      = var.ADMIN_PSWD
  tags                = var.tags

  size = "Standard_D2s_v3"

  network_interface_ids = [
    azurerm_network_interface.vm_sql_nic.id,
  ]

  os_disk {
    name                 = "vm-sql-osdisk-${var.tags.environment}-${var.rg_location}"
    caching              = "ReadWrite"
    disk_size_gb         = "127"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2019-WS2022"
    sku       = "Standard"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "sql_data_disk1" {
  location             = azurerm_resource_group.lab.location
  name                 = "vm-sql-disk-DATA-${var.tags.environment}-${var.rg_location}"
  resource_group_name  = azurerm_resource_group.lab.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 127
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.sql_data_disk1.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_sql.id
  lun                = 0
  caching            = "None"
}

resource "azurerm_managed_disk" "sql_logs_disk2" {
  location             = azurerm_resource_group.lab.location
  name                 = "vm-sql-disk-LOGS-${var.tags.environment}-${var.rg_location}"
  resource_group_name  = azurerm_resource_group.lab.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 63
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "logs_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.sql_logs_disk2.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_sql.id
  lun                = 1
  caching            = "None"
}

resource "azurerm_managed_disk" "sql_temp_disk3" {
  location             = azurerm_resource_group.lab.location
  name                 = "vm-sql-disk-TEMP-${var.tags.environment}-${var.rg_location}"
  resource_group_name  = azurerm_resource_group.lab.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 31
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "temp_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.sql_temp_disk3.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_sql.id
  lun                = 2
  caching            = "None"
}

resource "azurerm_mssql_virtual_machine" "azurerm_sqlvmmanagement" {
  virtual_machine_id               = azurerm_windows_virtual_machine.vm_sql.id
  sql_license_type                 = "PAYG"
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = local.generated_password
  sql_connectivity_update_username = var.SQL_ADMIN_USER

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }

  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "OLTP"

    data_settings {
      default_file_path = "F:\\SQL-Data"
      luns              = [0]
    }

    log_settings {
      default_file_path = "L:\\SQL-Logs"
      luns              = [1]
    }

    temp_db_settings {
      default_file_path = "T:\\SQL-Temp"
      luns              = [2]
    }
  }
}

resource "azurerm_virtual_machine_extension" "vm_sql_extension" {
  name                 = "sqlOutputScript"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_sql.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
    "commandToExecute": "echo ${local.generated_password} > C:\\sql-output.txt"
}
SETTINGS
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_shutown" {
  for_each = {
    "vm1" = azurerm_windows_virtual_machine.vm_jumpwin.id
    "vm2" = azurerm_linux_virtual_machine.vm_jumplin.id
    "vm3" = azurerm_windows_virtual_machine.vm_sql.id
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
