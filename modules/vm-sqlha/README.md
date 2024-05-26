# SQL High Availability (vm-sqlha) Terraform Module

This Terraform module deploys a SQL Server High Availability (HA) setup on Azure. It creates virtual machines, sets up necessary networking, configures SQL Server Always On availability groups, and manages resources required for a high availability SQL cluster.

## Usage

```powershell
module "vm_sqlha" {
  source                       = "./modules/vm-sqlha"
  lab_name                     = var.lab_name
  rg_location                  = azurerm_resource_group.mylab.location
  rg_name                      = azurerm_resource_group.mylab.name
  snet_sqlha_0064_db1_id       = data.azurerm_subnet.snet_0064_db1.id
  snet_sqlha_0096_db2_id       = data.azurerm_subnet.snet_0096_db2.id
  snet_sqlha_0064_db1_prefixes = data.azurerm_subnet.snet_0064_db1.address_prefixes
  snet_sqlha_0096_db2_prefixes = data.azurerm_subnet.snet_0096_db2.address_prefixes
  vm_sqlha_hostname            = var.vm_sqlha_hostname
  vm_sqlha_size                = var.vm_sqlha_size
  vm_localadmin_user           = var.vm_localadmin_user
  vm_localadmin_pswd           = var.vm_localadmin_pswd
  vm_sqlha_shutdown_hhmm       = var.vm_shutdown_hhmm
  vm_sqlha_shutdown_tz         = var.vm_shutdown_tz
  sql_sysadmin_login           = var.sql_service_account_login
  sql_sysadmin_password        = var.sql_sysadmin_password
  sql_service_account_login    = var.sql_service_account_login
  sql_service_account_password = var.sql_service_account_password
  sqlaag_name                  = var.sqlaag_name
  sqlcluster_name              = var.sqlcluster_name
  vm_addc_public_ip            = data.azurerm_public_ip.vm_addc_public_ip
  domain_name                  = var.domain_name
  domain_netbios_name          = var.domain_netbios_name
  domain_admin_user            = var.domain_admin_user
  domain_admin_pswd            = var.domain_admin_pswd
  tags                         = var.tags

  depends_on = [
    data.azurerm_subnet.snet_0064_db1,
    data.azurerm_subnet.snet_0096_db2,
    module.vm_addc,
  ]
}
```

## Resources

The module creates the following resources:

- **Virtual Machines** (`azurerm_windows_virtual_machine.vm_sqlha`)
- **Public IPs** (`azurerm_public_ip.vm_sqlha_pip`)
- **Network Interfaces** (`azurerm_network_interface.vm_sqlha_nic`)
- **Managed Disks** (`azurerm_managed_disk.vm_sqlha_*`)
- **SQL Server Setup** (`azurerm_mssql_virtual_machine`, `azurerm_mssql_virtual_machine_group`, `azurerm_mssql_virtual_machine_availability_group_listener`)
- **Extensions** (`azurerm_virtual_machine_extension.*`)
- **Storage Accounts and Containers** (`azurerm_storage_account.sqlha_stga`, `azurerm_storage_container.sqlha_quorum`)

## Variables

| Name                          | Type         | Description                                                                            | Default              |
|-------------------------------|--------------|----------------------------------------------------------------------------------------|----------------------|
| `lab_name`                    | `string`     | The name of the lab environment.                                                       | `mylab`              |
| `rg_location`                 | `string`     | The Azure location for the resource group.                                             | `westus`             |
| `rg_name`                     | `string`     | The name of the resource group.                                                        | `rg-mylab`           |
| `snet_sqlha_0064_db1_id`      | `string`     | The ID of the subnet 0064 db1.                                                         | n/a                  |
| `snet_sqlha_0096_db2_id`      | `string`     | The ID of the subnet 0096 db2.                                                         | n/a                  |
| `snet_sqlha_0064_db1_prefixes`| `list(string)`| The address prefixes of the subnet 0064 db1.                                            | n/a                  |
| `snet_sqlha_0096_db2_prefixes`| `list(string)`| The address prefixes of the subnet 0096 db2.                                            | n/a                  |
| `vm_sqlha_hostname`           | `string`     | The hostname prefix for the SQL HA VMs.                                                | `vm-sqlha`           |
| `vm_sqlha_size`               | `string`     | The size of the SQL HA VMs.                                                            | `Standard_D2s_v3`    |
| `vm_localadmin_user`          | `string`     | The local admin username for the VMs.                                                  | `localadmin`         |
| `vm_localadmin_pswd`          | `string`     | The local admin password for the VMs.                                                  | `P@ssw0rd!234`       |
| `vm_sqlha_shutdown_hhmm`      | `string`     | The time for VM shutdown in HHMM format.                                               | `0000`               |
| `vm_sqlha_shutdown_tz`        | `string`     | The time zone for VM shutdown.                                                         | `Pacific Standard Time`|
| `sql_sysadmin_login`          | `string`     | The login for the SQL sysadmin account.                                                | `sqladmin`           |
| `sql_sysadmin_password`       | `string`     | The password for the SQL sysadmin account.                                             | n/a                  |
| `sql_service_account_login`   | `string`     | The login for the SQL service account.                                                 | `sqlsvc`             |
| `sql_service_account_password`| `string`     | The password for the SQL service account.                                              | n/a                  |
| `sqlaag_name`                 | `string`     | The name of the SQL Always On availability group.                                      | `sqlaag`             |
| `sqlcluster_name`             | `string`     | The name of the SQL cluster.                                                           | `sqlcluster`         |
| `vm_addc_public_ip`           | `string`     | The public IP of the AD domain controller.                                             | n/a                  |
| `domain_name`                 | `string`     | The domain name.                                                                       | `mydomain.local`     |
| `domain_netbios_name`         | `string`     | The NetBIOS name of the domain.                                                        | `MYDOMAIN`           |
| `domain_admin_user`           | `string`     | The domain admin username.                                                             | `admin`              |
| `domain_admin_pswd`           | `string`     | The domain admin password.                                                             | n/a                  |
| `tags`                        | `map(string)`| A map of tags to assign to resources.                                                  | `{}`                 |

## Outputs

| Name                | Description                              |
|---------------------|------------------------------------------|
| `vm_sqlha_output`   | Outputs from the SQL HA module           |

## Notes

- Ensure that the necessary subnets and resource group exist before applying this module.
- Make sure to replace placeholder values with your actual Azure resource details.
- This module is designed for educational purposes and may require adjustments for production use.
- Follow best practices for managing sensitive information, such as using secure storage for passwords and other secrets.

## Contributions

Contributions are welcome. Please open an issue or submit a pull request if you have any suggestions, questions, or would like to contribute to the project.

### GNU General Public License
This script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this script. If not, see <https://www.gnu.org/licenses/>.