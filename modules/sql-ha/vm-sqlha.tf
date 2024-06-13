#################### vm-sqlha ####################
########## vm-sqlha
# vm-sqlha Public IP with internet DNS hostname
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
  dns_servers = [
    azurerm_network_interface.vm_addc_nic.ip_configuration[0].private_ip_address, "1.1.1.1", "8.8.8.8",
  ]
  lifecycle {
    ignore_changes = [tags, ip_configuration]
  }
}

# Create vm-sqlha
# vm-sqlha associate NICs with NSG
resource "azurerm_network_interface_security_group_association" "vm_sqlha_nsg_assoc" {
  count                     = var.vm_sqlha_count
  network_interface_id      = azurerm_network_interface.vm_sqlha_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_server.id
}

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
  /*eviction_policy     = "Deallocate"
  priority            = "Spot"
  max_bid_price       = -1*/
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

# vm-sqlha extension to OpenSSH
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

# vm-sqlha managed disk - data
resource "azurerm_managed_disk" "vm_sqlha_data" {
  count                = var.vm_sqlha_count
  name                 = "${var.vm_sqlha_hostname}0${count.index + 1}-dsk-data"
  location             = var.rg_location
  resource_group_name  = var.rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 45
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
resource "azurerm_managed_disk" "vm_sqlha_logs" {
  count                = var.vm_sqlha_count
  name                 = "${var.vm_sqlha_hostname}0${count.index + 1}-dsk-logs"
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
resource "azurerm_virtual_machine_data_disk_attachment" "vm_sqlha_logs" {
  count              = var.vm_sqlha_count
  managed_disk_id    = azurerm_managed_disk.vm_sqlha_logs[count.index].id
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
  disk_size_gb         = 15
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

resource "azurerm_virtual_machine_run_command" "vm_sqlha_restart" {
  count              = var.vm_sqlha_count
  name               = "RestartCommand"
  location           = var.rg_location
  virtual_machine_id = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  source {
    script = "powershell.exe -ExecutionPolicy Unrestricted -NoProfile -Command Restart-Computer -Force"
  }
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.vm_sqlha_data,
    azurerm_virtual_machine_data_disk_attachment.vm_sqlha_logs,
    azurerm_virtual_machine_data_disk_attachment.vm_sqlha_temp,
  ]
}

resource "time_sleep" "vm_sqlha_restart_wait" {
  count           = var.vm_sqlha_count
  create_duration = "3m"
  depends_on = [
    azurerm_virtual_machine_run_command.vm_sqlha_restart,
  ]
}

resource "null_resource" "vm_sqlAddLocalAdmin_copy" {
  count = var.vm_sqlha_count
  provisioner "file" {
    source      = "${path.module}/${local.sqlAddLocalAdmin}"
    destination = "C:\\${local.sqlAddLocalAdmin}"
    connection {
      type            = "ssh"
      user            = var.vm_sqlha_localadmin_user
      password        = var.vm_sqlha_localadmin_pswd
      host            = azurerm_public_ip.vm_sqlha_pip[count.index].ip_address
      target_platform = "windows"
      timeout         = "3m"
    }
  }
  depends_on = [
    time_sleep.vm_sqlha_restart_wait
  ]
}

resource "null_resource" "vm_ssqlAddSysAdmins_copy" {
  count = var.vm_sqlha_count
  provisioner "file" {
    source      = "${path.module}/${local.sqlAddSysAdmins}"
    destination = "C:\\${local.sqlAddSysAdmins}"
    connection {
      type            = "ssh"
      user            = var.vm_sqlha_localadmin_user
      password        = var.vm_sqlha_localadmin_pswd
      host            = azurerm_public_ip.vm_sqlha_pip[count.index].ip_address
      target_platform = "windows"
      timeout         = "3m"
    }
  }
  depends_on = [
    null_resource.vm_sqlAddLocalAdmin_copy
  ]
}

# Extension to domain join SQL servers
resource "azurerm_virtual_machine_extension" "vm_sqlha_domain_join" {
  count                = var.vm_sqlha_count
  name                 = "SQL${count.index + 1}DomainJoin"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  settings             = <<SETTINGS
  {
    "Name": "${var.domain_name}",
    "OUPath": "${local.servers_ou_path}",
    "User": "${var.domain_netbios_name}\\${var.vm_addc_localadmin_user}",
    "Restart": "true",
    "Options": "3"
  }
SETTINGS
  protected_settings   = <<PROTECTED_SETTINGS
  {
    "Password": "${var.vm_addc_localadmin_pswd}"
  }
PROTECTED_SETTINGS
  depends_on = [
    null_resource.vm_ssqlAddSysAdmins_copy,
    null_resource.vm_addc_add_users,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

# Time delay after SQL domain join
resource "time_sleep" "vm_sqlha_domain_join_wait" {
  count           = var.vm_sqlha_count
  create_duration = "5m"
  depends_on = [
    azurerm_virtual_machine_extension.vm_sqlha_domain_join,
  ]
}

# Add 'domain\sqlinstall' account to local administrators group on SQL servers
resource "null_resource" "sqlsvc_local_admin" {
  count = var.vm_sqlha_count
  # SSH connection to target SQL server with domain_netbios_name\domain_admin account
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
      "powershell.exe -ExecutionPolicy Unrestricted -NoProfile -File C:\\${local.sqlAddLocalAdmin} -domain_name ${var.domain_name} -sql_svc_acct_user ${var.sql_svc_acct_user}"
    ]
  }
  depends_on = [
    time_sleep.vm_sqlha_domain_join_wait,
    null_resource.vm_addc_add_users,
  ]
}

# Add the 'domain\sqlinstall' account to sysadmin roles on SQL servers
resource "null_resource" "sql_sysadmin" {
  count = var.vm_sqlha_count
  # SSH connection to target SQL server with domain_admin account
  provisioner "remote-exec" {
    connection {
      type            = "ssh"
      user            = var.vm_addc_localadmin_user
      password        = var.vm_addc_localadmin_pswd
      host            = azurerm_public_ip.vm_sqlha_pip[count.index].ip_address
      target_platform = "windows"
      timeout         = "5m"
    }
    inline = [
      "powershell.exe -ExecutionPolicy Unrestricted -NoProfile -File C:\\${local.sqlAddSysAdmins} -domain_netbios_name ${var.domain_netbios_name} -domain_admin ${var.vm_addc_localadmin_user} -sql_sysadmin_user ${var.sql_sysadmin_user} -sql_sysadmin_pswd ${var.sql_sysadmin_pswd}"
    ]
  }
  depends_on = [
    null_resource.sqlsvc_local_admin,
  ]
}

# Time delay after SQL domain join
resource "time_sleep" "vm_sql_sysadmin_wait" {
  create_duration = "5m"
  depends_on = [
    null_resource.sql_sysadmin,
  ]
}

# Indicates the capability to manage a group of virtual machines specific to Microsoft SQL
resource "azurerm_mssql_virtual_machine_group" "sqlha_vmg" {
  name                = var.sql_cluster_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sql_image_offer     = var.sql_image_offer
  sql_image_sku       = var.sql_image_sku
  wsfc_domain_profile {
    fqdn                           = var.domain_name
    cluster_subnet_type            = "MultiSubnet"
    cluster_bootstrap_account_name = "sqlinstall@${var.domain_name}"
    cluster_operator_account_name  = "sqlinstall@${var.domain_name}"
    sql_service_account_name       = "${var.sql_svc_acct_user}@${var.domain_name}"
    organizational_unit_path       = local.servers_ou_path
    storage_account_primary_key    = azurerm_storage_account.sqlha_stga.primary_access_key
    storage_account_url            = "${azurerm_storage_account.sqlha_stga.primary_blob_endpoint}${azurerm_storage_container.sqlha_quorum.name}"
  }
  depends_on = [
    time_sleep.vm_sql_sysadmin_wait,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

# Time delay after SQL domain join
resource "time_sleep" "sqlha_vmg_wait" {
  create_duration = "5m"
  depends_on = [
    azurerm_mssql_virtual_machine_group.sqlha_vmg,
  ]
}

# vm-sqlha MSSQL configuration - this can take 15-30 minutes!
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
      luns              = [azurerm_virtual_machine_data_disk_attachment.vm_sqlha_logs[count.index].lun]
    }
    temp_db_settings {
      default_file_path = var.sqltempfilepath
      luns              = [azurerm_virtual_machine_data_disk_attachment.vm_sqlha_temp[count.index].lun]
    }
  }
  depends_on = [
    null_resource.sql_sysadmin,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "time_sleep" "az_sqlha_wait" {
  create_duration = "5m"
  depends_on = [
    azurerm_mssql_virtual_machine.az_sqlha,
  ]
}

# Create special permission for base OU for Cluster computer object
resource "null_resource" "cluster_acl" {
  provisioner "remote-exec" {
    connection {
      type            = "ssh"
      user            = var.vm_addc_localadmin_user
      password        = var.vm_addc_localadmin_pswd
      host            = var.vm_addc_public_ip
      target_platform = "windows"
      timeout         = "3m"
    }
    inline = [
      "powershell.exe -ExecutionPolicy Unrestricted -NoProfile -File C:\\${local.sqlAddAcl} -domain_name ${var.domain_name} -sqlcluster_name ${var.sql_cluster_name}"
    ]
  }
  depends_on = [
    azurerm_mssql_virtual_machine_group.sqlha_vmg,
  ]
}

resource "time_sleep" "cluster_acl_wait" {
  create_duration = "5m"
  depends_on = [
    null_resource.cluster_acl,
  ]
}

# Create Always-On availability listener for SQL cluster with multi-subnet configuration
resource "azurerm_mssql_virtual_machine_availability_group_listener" "sql_aag" {
  name                         = var.sql_listener
  availability_group_name      = var.sql_ag_name
  port                         = 1433
  sql_virtual_machine_group_id = azurerm_mssql_virtual_machine_group.sqlha_vmg.id
  multi_subnet_ip_configuration {
    private_ip_address     = cidrhost(var.snet_0064_db1_prefixes[0], 25) // "10.0.0.89"
    sql_virtual_machine_id = azurerm_mssql_virtual_machine.az_sqlha[0].id
    subnet_id              = var.snet_0064_db1_id
  } // "10.0.0.70"
  multi_subnet_ip_configuration {
    private_ip_address     = cidrhost(var.snet_0096_db2_prefixes[0], 25) // "10.0.0.121"
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
    null_resource.cluster_acl,
  ]
}

resource "time_sleep" "az_sql_aag_wait" {
  create_duration = "5m"
  depends_on = [
    azurerm_mssql_virtual_machine_availability_group_listener.sql_aag,
  ]
}

# vm-sqlha AUTOSHUTDOWN
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_sqlha_shutdown" {
  count                 = var.vm_sqlha_count
  virtual_machine_id    = azurerm_windows_virtual_machine.vm_sqlha[count.index].id
  location              = var.rg_location
  enabled               = true
  daily_recurrence_time = var.vm_sqlha_shutdown_hhmm
  timezone              = var.vm_shutdown_tz
  notification_settings {
    enabled = false
  }
  depends_on = [
    time_sleep.az_sql_aag_wait,
  ]
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
  depends_on = [
    azurerm_dev_test_global_vm_shutdown_schedule.vm_sqlha_shutdown,
  ]
}
