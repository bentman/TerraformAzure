#################### vm-sqlha ####################
########## vm-sqlha cluster storage
# storage account for cloud sql-witness
resource "azurerm_storage_account" "sqlha_stga" {
  name                     = "sqlstgwitnes"
  location                 = var.rg_location
  resource_group_name      = var.rg_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# blob container cloud sql-quorum
resource "azurerm_storage_container" "sqlha_quorum" {
  name                  = "sqlstgquorum"
  storage_account_name  = azurerm_storage_account.sqlha_stga.name
  container_access_type = "private"
}

########## vm-sqlha
# vm-sqlha Publip IP with internet DNS hostname
resource "azurerm_public_ip" "vm_sqlha_pip" {
  count               = var.vm_sqlha_count
  name                = "${var.vm_sqlha_hostname}0${count.index + 1}-pip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.vm_sqlha_hostname}0${count.index + 1}"
  zones               = ["${count.index + 1}"]
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-sqlha primary NIC 
resource "azurerm_network_interface" "vm_sqlha_nic" {
  count                         = var.vm_sqlha_count
  name                          = "${var.vm_sqlha_hostname}0${count.index + 1}-nic"
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  enable_accelerated_networking = true
  tags                          = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
  ip_configuration {
    name                          = "${var.vm_sqlha_hostname}0${count.index + 1}-ip" // "10.0.0.73" & "10.0.0.105"
    subnet_id                     = count.index == 0 ? var.snet_0064_db1_id : var.snet_0096_db2_id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(count.index == 0 ? var.snet_0064_db1_prefixes[0] : var.snet_0096_db2_prefixes[0], 9)
    public_ip_address_id          = azurerm_public_ip.vm_sqlha_pip[count.index].id
    primary                       = true
  }
  ip_configuration {
    name                          = "${var.vm_sqlha_hostname}0${count.index + 1}-ip-cluster" // "10.0.0.74" & "10.0.0.106"
    subnet_id                     = count.index == 0 ? var.snet_0064_db1_id : var.snet_0096_db2_id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(count.index == 0 ? var.snet_0064_db1_prefixes[0] : var.snet_0096_db2_prefixes[0], 10)
  }
  ip_configuration {
    name                          = "${var.vm_sqlha_hostname}0${count.index + 1}-ip-listener" // "10.0.0.75" & "10.0.0.107"
    subnet_id                     = count.index == 0 ? var.snet_0064_db1_id : var.snet_0096_db2_id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(count.index == 0 ? var.snet_0064_db1_prefixes[0] : var.snet_0096_db2_prefixes[0], 11)
  }
  # Must be set and restart the computer to reach the domain controller and DNS
  dns_servers = [var.vm_addc_private_ip, "1.1.1.1", "8.8.8.8"]
}

########## vm-sqlha
resource "azurerm_windows_virtual_machine" "vm_sqlha" {
  count               = var.vm_sqlha_count
  name                = "${var.vm_sqlha_hostname}0${count.index + 1}"
  location            = var.rg_location
  resource_group_name = var.rg_name
  size                = var.vm_sqlha_size
  computer_name       = "${var.vm_sqlha_hostname}0${count.index + 1}"
  admin_username      = var.vm_sqlha_localadmin_user
  admin_password      = var.vm_sqlha_localadmin_pswd
  license_type        = "Windows_Server"
  zone                = count.index + 1
  tags                = var.tags
  network_interface_ids = [
    azurerm_network_interface.vm_sqlha_nic[count.index].id
  ]
  source_image_reference {
    publisher = var.vm_sqlha_image_publisher
    offer     = var.vm_sqlha_image_offer
    sku       = var.vm_sqlha_image_sku
    version   = "latest"
  }
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    name                 = "${var.vm_sqlha_hostname}0${count.index + 1}-dsk-0S"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 127
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-sqlha associate NICs with NSG
resource "azurerm_network_interface_security_group_association" "vm_sqlha_nsg_assoc" {
  count                     = var.vm_sqlha_count
  network_interface_id      = azurerm_network_interface.vm_sqlha_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_server.id
}

# vm-sqlha extension to Open SSH
resource "azurerm_virtual_machine_extension" "openssh_sqlha" {
  count                      = var.vm_sqlha_count
  name                       = "InstallOpenSSH"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  publisher                  = "Microsoft.Azure.OpenSSH"
  type                       = "WindowsOpenSSH"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_windows_virtual_machine.vm_sqlha,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

# Set VM timezone
resource "azurerm_virtual_machine_run_command" "vm_timezone_sqlha" {
  count              = var.vm_sqlha_count
  name               = "SetTimeZone"
  location           = var.rg_location
  virtual_machine_id = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  source {
    script = "Set-TimeZone -Name '${var.vm_shutdown_tz}' -Confirm:$false"
  }
  depends_on = [azurerm_virtual_machine_extension.openssh_sqlha]
}

# vm-sqlha managed disk - data
resource "azurerm_managed_disk" "vm_sqlha_data" {
  count                = var.vm_sqlha_count
  name                 = "${var.vm_sqlha_hostname}0${count.index + 1}-dsk-data"
  location             = var.rg_location
  resource_group_name  = var.rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 50
  zone                 = count.index + 1
  tags                 = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-sqlha managed disk attachment - data = LUN-0
resource "azurerm_virtual_machine_data_disk_attachment" "vm_sqlha_data" {
  count              = var.vm_sqlha_count
  managed_disk_id    = azurerm_managed_disk.vm_sqlha_data[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
}

# vm-sqlha managed disk - logs
resource "azurerm_managed_disk" "vm_sqlha_log" {
  count                = var.vm_sqlha_count
  name                 = "${var.vm_sqlha_hostname}0${count.index + 1}-dsk-log"
  location             = var.rg_location
  resource_group_name  = var.rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 30
  zone                 = count.index + 1
  tags                 = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-sqlha managed disk attachment - logs = LUN-1
resource "azurerm_virtual_machine_data_disk_attachment" "vm_sqlha_log" {
  count              = var.vm_sqlha_count
  managed_disk_id    = azurerm_managed_disk.vm_sqlha_log[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  lun                = "1"
  caching            = "ReadWrite"
}

# vm-sqlha managed disk - temp
resource "azurerm_managed_disk" "vm_sqlha_temp" {
  count                = var.vm_sqlha_count
  name                 = "${var.vm_sqlha_hostname}0${count.index + 1}-dsk-temp"
  location             = var.rg_location
  resource_group_name  = var.rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 20
  zone                 = count.index + 1
  tags                 = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# vm-sqlha managed disk attachment - temp = LUN-2
resource "azurerm_virtual_machine_data_disk_attachment" "vm_sqlha_temp" {
  count              = var.vm_sqlha_count
  managed_disk_id    = azurerm_managed_disk.vm_sqlha_temp[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  lun                = "2"
  caching            = "ReadWrite"
}

resource "azurerm_mssql_virtual_machine" "az_sqlha" {
  count                            = var.vm_sqlha_count
  virtual_machine_id               = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  sql_license_type                 = "PAYG"
  sql_virtual_machine_group_id     = azurerm_mssql_virtual_machine_group.sqlha_vmg.id
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = var.sql_sysadmin_pswd
  sql_connectivity_update_username = var.sql_sysadmin_user
  wsfc_domain_credential {
    cluster_bootstrap_account_password = var.sql_svc_acct_pswd # install account
    cluster_operator_account_password  = var.sql_svc_acct_pswd # install account
    sql_service_account_password       = var.sql_svc_acct_pswd # sqlsvc account
  }
  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "GENERAL"
    data_settings {
      default_file_path = var.sqldatafilepath
      luns              = [azurerm_virtual_machine_data_disk_attachment.vm_sqlha_data[count.index].lun]
    }
    log_settings {
      default_file_path = var.sqllogfilepath
      luns              = [azurerm_virtual_machine_data_disk_attachment.vm_sqlha_log[count.index].lun]
    }
    temp_db_settings {
      default_file_path = var.sqltempfilepath
      luns              = [azurerm_virtual_machine_data_disk_attachment.vm_sqlha_temp[count.index].lun]
    }
  }
  depends_on = [
    azurerm_windows_virtual_machine.vm_sqlha,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

# extension to domain join SQL servers
resource "azurerm_virtual_machine_extension" "vm_sqlha_domain_join" {
  count                = var.vm_sqlha_count
  name                 = "SQL${count.index + 1}DomainJoin"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = <<SETTINGS
  {
    "Name": "${var.domain_name}",
    "OUPath": "${local.servers_ou_path}",
    "User": "${var.domain_netbios_name}\\${var.domain_admin_user}",
    "Restart": "true",
    "Options": "3"
  }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "Password": "${var.domain_admin_pswd}"
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_windows_virtual_machine.vm_sqlha,
    terraform_data.vm_addc_add_users,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

# time delay after SQL domain join
resource "time_sleep" "vm_sqljoin" {
  create_duration = "3m"
  depends_on      = [azurerm_virtual_machine_extension.vm_sqlha_domain_join, ]
}

# add 'domain\sqlinstall' account to local administrators group on SQL servers
resource "terraform_data" "sqlsvc_local_admin" {
  count = var.vm_sqlha_count
  triggers_replace = [
    azurerm_virtual_machine_extension.vm_sqlha_domain_join[count.index].id,
    time_sleep.vm_sqljoin.id
  ]
  # SSH connection to target SQL server with domain admin account
  provisioner "remote-exec" {
    connection {
      type            = "ssh"
      user            = "${var.domain_netbios_name}\\${var.vm_addc_localadmin_user}"
      password        = var.vm_addc_localadmin_pswd
      host            = azurerm_public_ip.vm_sqlha_pip[count.index].ip_address
      target_platform = "windows"
      timeout         = "5m"
    }
    inline = [
      "powershell.exe -Command \"${join(";", local.powershell_local_admin)}\""
    ]
  }
  depends_on = [
    azurerm_virtual_machine_extension.openssh_sqlha,
    terraform_data.vm_addc_add_users,
    time_sleep.vm_sqljoin,
  ]
}

# Add the 'domain\sqlinstall' account to sysadmin roles on SQL servers
resource "terraform_data" "sql_sysadmin" {
  count = var.vm_sqlha_count
  triggers_replace = [
    azurerm_virtual_machine_extension.vm_sqlha_domain_join[count.index].id,
    terraform_data.sqlsvc_local_admin[count.index].id
  ]
  # SSH connection to target SQL server with local admin account
  provisioner "remote-exec" {
    connection {
      type            = "ssh"
      user            = "${var.domain_netbios_name}\\${var.vm_addc_localadmin_user}"
      password        = var.vm_addc_localadmin_pswd
      host            = var.vm_addc_public_ip
      target_platform = "windows"
      timeout         = "5m"
    }
    inline = [
      "powershell.exe -Command \"${join(";", local.powershell_sql_sysadmin)}\""
    ]
  }
  depends_on = [
    terraform_data.vm_addc_add_users,
    terraform_data.sqlsvc_local_admin,
  ]
}

# Indicates the capability to manage a group of virtual machines specific to Microsoft SQL
resource "azurerm_mssql_virtual_machine_group" "sqlha_vmg" {
  name                = var.sqlcluster_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sql_image_offer     = var.sql_image_offer
  sql_image_sku       = var.sql_image_sku
  wsfc_domain_profile {
    fqdn                           = var.domain_name
    cluster_subnet_type            = "MultiSubnet"
    cluster_bootstrap_account_name = "sqlinstall@${var.domain_name}"
    cluster_operator_account_name  = "sqlinstall@${var.domain_name}"
    sql_service_account_name       = "sqlsvc@${var.domain_name}"
    organizational_unit_path       = local.servers_ou_path
    storage_account_primary_key    = azurerm_storage_account.sqlha_stga.primary_access_key
    storage_account_url            = "${azurerm_storage_account.sqlha_stga.primary_blob_endpoint}${azurerm_storage_container.sqlha_quorum.name}"
  }
  depends_on = [
    terraform_data.sql_sysadmin,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

# Create special permission for base OU for Cluster computer object
resource "terraform_data" "cluster_acl" {
  triggers_replace = [azurerm_mssql_virtual_machine.az_sqlha[*].id]
  # With SSH connection
  provisioner "remote-exec" {
    connection {
      type            = "ssh"
      user            = "${var.domain_netbios_name}\\${var.vm_addc_localadmin_user}"
      password        = var.vm_addc_localadmin_pswd
      host            = var.vm_addc_public_ip
      target_platform = "windows"
      timeout         = "5m"
    }
    inline = [
      "powershell.exe -Command \"${join(";", local.powershell_acl_commands)}\""
    ]
  }
  depends_on = [
    azurerm_mssql_virtual_machine.az_sqlha,
  ]
}

# Create Always-On availability listener for SQL cluster with multi-subnet configuration
resource "azurerm_mssql_virtual_machine_availability_group_listener" "aag" {
  name                         = "sqlha-listener" # Length of the name (1-15)
  availability_group_name      = "sqlhaaag"
  port                         = 1433
  sql_virtual_machine_group_id = azurerm_mssql_virtual_machine_group.sqlha_vmg.id
  multi_subnet_ip_configuration {
    private_ip_address     = cidrhost(var.snet_0064_db1_prefixes[0], 6)
    sql_virtual_machine_id = azurerm_mssql_virtual_machine.az_sqlha[0].id
    subnet_id              = var.snet_0064_db1_id
  } // "10.0.0.70"
  multi_subnet_ip_configuration {
    private_ip_address     = cidrhost(var.snet_0096_db2_prefixes[0], 6)
    sql_virtual_machine_id = azurerm_mssql_virtual_machine.az_sqlha[1].id
    subnet_id              = var.snet_0096_db2_id
  } // "10.0.0.102"
  replica {
    sql_virtual_machine_id = azurerm_mssql_virtual_machine.az_sqlha[0].id
    role                   = "Primary"
    commit                 = "Synchronous_Commit"
    failover_mode          = "Automatic"
    readable_secondary     = "No"
  }
  replica {
    sql_virtual_machine_id = azurerm_mssql_virtual_machine.az_sqlha[1].id
    role                   = "Secondary"
    commit                 = "Synchronous_Commit"
    failover_mode          = "Automatic"
    readable_secondary     = "No"
  }
  timeouts {
    create = "15m"
  }
  depends_on = [
    terraform_data.cluster_acl,
  ]
}

# vm-sqlha AUTOSHUTDOWN
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_sqlha_shutown" {
  count                 = var.vm_sqlha_count
  virtual_machine_id    = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  location              = var.rg_location
  enabled               = true
  daily_recurrence_time = var.vm_sqlha_shutdown_hhmm
  timezone              = var.vm_shutdown_tz
  depends_on = [
    azurerm_windows_virtual_machine.vm_sqlha,
  ]
  notification_settings {
    enabled = false
  }
}
