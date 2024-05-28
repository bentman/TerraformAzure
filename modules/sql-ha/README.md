# Module for Domain Controller and SQL High Availability on Azure Virtual Machines

This Terraform module deploys an Active Directory Domain Controller along with a high availability SQL Server cluster in Azure.
It is designed for creating a robust and scalable infrastructure for SQL Server and Active Directory services.

## Overview

This module sets up the following:

- **Active Directory Domain Controller (VM ADDC)**: Deploys a Windows Server configured as an Active Directory Domain Controller.
- **SQL High Availability (SQL HA)**: Deploys SQL servers in a high availability configuration with necessary network, storage, and security settings.

## Usage

### SQL HA Module

```hcl
module "sql_ha" {
  count                    = var.module_sql_ha_enable ? 1 : 0
  source                   = "./modules/sql-ha"
  lab_name                 = var.lab_name
  rg_name                  = azurerm_resource_group.mylab.name
  rg_location              = azurerm_resource_group.mylab.location
  snet_0128_server_id      = data.azurerm_subnet.snet_0128_server.id
  snet_0064_db1_id         = data.azurerm_subnet.snet_0064_db1.id
  snet_0096_db2_id         = data.azurerm_subnet.snet_0096_db2.id
  snet_0064_db1_prefixes   = data.azurerm_subnet.snet_0064_db1.address_prefixes
  snet_0096_db2_prefixes   = data.azurerm_subnet.snet_0096_db2.address_prefixes
  domain_name              = var.domain_name
  domain_netbios_name      = var.domain_netbios_name
  safemode_admin_pswd      = var.safemode_admin_pswd
  vm_shutdown_tz           = var.vm_shutdown_tz
  vm_addc_hostname         = var.vm_addc_hostname
  vm_addc_localadmin_user  = var.domain_admin_user //NOTE: becomes domain admin after dcpromo
  vm_addc_localadmin_pswd  = var.domain_admin_pswd //NOTE: becomes domain admin after dcpromo
  vm_addc_size             = var.vm_addc_size
  vm_addc_public_ip        = module.vm_addc[0].vm_addc_public_ip
  vm_addc_private_ip       = module.vm_addc[0].vm_addc_private_ip
  vm_sqlha_hostname        = var.vm_sqlha_hostname
  vm_sqlha_size            = var.vm_sqlha_size
  vm_sqlha_localadmin_user = var.vm_localadmin_user
  vm_sqlha_localadmin_pswd = var.vm_localadmin_pswd
  vm_sqlha_shutdown_hhmm   = var.vm_shutdown_hhmm
  sql_sysadmin_user        = var.sql_sysadmin_user
  sql_sysadmin_pswd        = var.sql_sysadmin_pswd
  sql_svc_acct_user        = var.sql_svc_acct_user
  sql_svc_acct_pswd        = var.sql_svc_acct_pswd
  sqlaag_name              = var.sqlaag_name
  sqlcluster_name          = var.sqlcluster_name
  tags                     = var.tags
  depends_on = [
    azurerm_subnet.snet_0128_server,
    azurerm_subnet.snet_0064_db1,
    azurerm_subnet.snet_0096_db2,
  ]
}
```

## Variables

### Common Variables

| Name                  | Type     | Description                                         | Default                          |
| --------------------- | -------- | --------------------------------------------------- | -------------------------------- |
| `lab_name`            | `string` | The name of the lab environment                     | 'mylab'                          |
| `rg_location`         | `string` | The location of the resource group                  | 'westus'                         |
| `tags`                | `map`    | A map of tags to apply to the resources             | `{}`                             |
| `vm_shutdown_tz`      | `string` | The timezone for VM shutdown                        | 'Pacific Standard Time"          |
| `domain_name`         | `string` | The domain name for Active Directory                | 'mylab.mytenant.onmicrosoft.lan' |
| `domain_netbios_name` | `string` | The NetBIOS name for the domain                     | 'MYLAB'                          |
| `safemode_admin_pswd` | `string` | The password for the safemode administrator account | 'P@ssw0rd!234'                      |
| `vm_localadmin_user`  | `string` | The local admin username for the VMs                | 'localadmin'                     |
| `vm_localadmin_pswd`  | `string` | The local admin password for the VMs                | 'P@ssw0rd!234'                   |

### SQL HA Module Variables

| Name                     | Type     | Description                                      | Default           |
| ------------------------ | -------- | ------------------------------------------------ | ----------------- |
| `vm_sqlha_hostname`      | `string` | The hostname for the SQL HA VMs                  | 'vm-sqlha'        |
| `vm_sqlha_size`          | `string` | The size of the SQL HA VMs                       | 'Standard_D2s_v3' |
| `vm_sqlha_shutdown_hhmm` | `string` | The time for VM shutdown in HHMM format          | '0000'            |
| `sqlaag_name`            | `string` | The name of the SQL Always-On Availability Group | 'sqlhaaoaag'      |
| `sqlcluster_name`        | `string` | The name of the SQL cluster                      | 'sqlcluster'      |
| `sql_sysadmin_user`      | `string` | The SQL sysadmin username                        | 'sqladmin'        |
| `sql_sysadmin_pswd`      | `string` | The SQL sysadmin password                        | 'P@ssw0rd!234'    |
| `sql_svc_acct_user`      | `string` | The SQL service account username                 | 'sqlsvc'          |
| `sql_svc_acct_pswd`      | `string` | The SQL service account password                 | 'P@ssw0rd!234'    |

### Domain Controller Module Variables

| Name                    | Type     | Description                               | Default           |
| ----------------------- | -------- | ----------------------------------------- | ----------------- |
| `vm_addc_hostname`      | `string` | The hostname for the Domain Controller VM | 'vm-addc'         |
| `vm_addc_size`          | `string` | The size of the Domain Controller VM      | 'Standard_D2s_v3' |
| `vm_addc_shutdown_hhmm` | `string` | The time for VM shutdown in HHMM format   | '0015'            |

## Notes

- This module assumes that the necessary resource group is already created and available.
- Ensure you replace all placeholders with your actual values in `terraform.tfvars`.

## Contributions

Contributions are welcome. Please open an issue or submit a pull request if you have any suggestions, questions, or would like to contribute to the project.

### GNU General Public License

This script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this script. If not, see <https://www.gnu.org/licenses/>.
