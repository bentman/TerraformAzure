Here is the combined README.md file for the merged module, using `***` instead of ` ``` ` for embedded code blocks:

***

# SQL High Availability with Active Directory Domain Controller Module

This Terraform module creates an Active Directory Domain Controller (AD DC) and SQL High Availability (SQL HA) setup in Azure. The module handles the provisioning of necessary infrastructure components, including virtual networks, subnets, public IP addresses, NAT gateways, network security groups, and virtual machines configured for high availability.

## Usage

To use this module, include it in your Terraform configuration and pass the required variables.

***
module "sql_ha" {
  count                    = var.module_vm_addc_enable ? 1 : 0
  source                   = "./modules/sql-ha"
  lab_name                 = var.lab_name
  rg_name                  = azurerm_resource_group.mylab.name
  rg_location              = azurerm_resource_group.mylab.location
  snet_0128_server_id      = azurerm_subnet.snet_0128_server.id
  snet_0064_db1_id         = azurerm_subnet.snet_0064_db1.id
  snet_0096_db2_id         = azurerm_subnet.snet_0096_db2.id
  snet_0064_db1_prefixes   = azurerm_subnet.snet_0064_db1.address_prefixes
  snet_0096_db2_prefixes   = azurerm_subnet.snet_0096_db2.address_prefixes
  domain_name              = var.domain_name
  domain_netbios_name      = var.domain_netbios_name
  safemode_admin_pswd      = var.safemode_admin_pswd
  vm_shutdown_tz           = var.vm_shutdown_tz
  vm_addc_hostname         = var.vm_addc_hostname
  vm_addc_size             = var.vm_addc_size
  vm_addc_localadmin_user  = var.domain_admin_user //NOTE: becomes domain admin after dcpromo
  vm_addc_localadmin_pswd  = var.domain_admin_pswd //NOTE: becomes domain admin after dcpromo
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
***

## Resources

The module creates the following resources:

- **Active Directory Domain Controller (AD DC)**
  - Public IP
  - Network Interface
  - Windows Virtual Machine
  - Domain Controller Promotion
  - Dev/Test Auto Shutdown
  - OpenSSH Extension
  - Network Security Group (NSG)

- **SQL High Availability (SQL HA)**
  - Storage Account for Cloud SQL Witness
  - Blob Container for Cloud SQL Quorum
  - Public IPs for SQL VMs
  - Network Interfaces for SQL VMs
  - Windows Virtual Machines for SQL
  - Managed Disks for SQL Data, Logs, and Temp
  - Dev/Test Auto Shutdown for SQL VMs
  - OpenSSH Extension for SQL VMs
  - Domain Join for SQL VMs
  - Local Admin Configuration on SQL VMs
  - SQL Admin Configuration
  - SQL Cluster Configuration
  - Availability Group Listener

## Variables

| Name                      | Type   | Description                                      | Default                     |
|---------------------------|--------|--------------------------------------------------|-----------------------------|
| `lab_name`                | string | The name of the lab environment                  | `mylab`                     |
| `rg_name`                 | string | The name of the resource group                   | `rg-mylab`                  |
| `rg_location`             | string | The location of the resource group               | `westus`                    |
| `snet_0128_server_id`     | string | The ID of the subnet for server                  | n/a                         |
| `snet_0064_db1_id`        | string | The ID of the subnet for database 1              | n/a                         |
| `snet_0096_db2_id`        | string | The ID of the subnet for database 2              | n/a                         |
| `snet_0064_db1_prefixes`  | list   | The address prefixes of the subnet for db1       | n/a                         |
| `snet_0096_db2_prefixes`  | list   | The address prefixes of the subnet for db2       | n/a                         |
| `domain_name`             | string | The domain name                                  | `mylab.mytenant.onmicrosoft.com` |
| `domain_netbios_name`     | string | The NetBIOS name of the domain                   | `MYLAB`                     |
| `safemode_admin_pswd`     | string | The safe mode admin password                     | `P@ssw0rd!234`              |
| `vm_shutdown_tz`          | string | The time zone for VM shutdown                    | `Pacific Standard Time`     |
| `vm_addc_hostname`        | string | The hostname for the AD DC                       | `vmaddc`                    |
| `vm_addc_size`            | string | The size of the AD DC VM                         | `Standard_D2s_v3`           |
| `vm_addc_localadmin_user` | string | The local admin username for AD DC               | `domain_admin_user`         |
| `vm_addc_localadmin_pswd` | string | The local admin password for AD DC               | `domain_admin_pswd`         |
| `vm_addc_public_ip`       | string | The public IP of the AD DC                       | n/a                         |
| `vm_addc_private_ip`      | string | The private IP of the AD DC                      | n/a                         |
| `vm_sqlha_hostname`       | string | The hostname for the SQL HA VMs                  | `vm-sqlha`                  |
| `vm_sqlha_size`           | string | The size of the SQL HA VMs                       | `Standard_DS1_v2`           |
| `vm_sqlha_localadmin_user`| string | The local admin username for SQL HA VMs          | `localadmin`                |
| `vm_sqlha_localadmin_pswd`| string | The local admin password for SQL HA VMs          | `P@ssw0rd!234`              |
| `vm_sqlha_shutdown_hhmm`  | string | The time for SQL HA VM shutdown                  | `0000`                      |
| `sql_sysadmin_user`       | string | The SQL sysadmin username                        | `sqladmin`                  |
| `sql_sysadmin_pswd`       | string | The SQL sysadmin password                        | `P@ssw0rd!234`              |
| `sql_svc_acct_user`       | string | The SQL service account username                 | `sqlsvc`                    |
| `sql_svc_acct_pswd`       | string | The SQL service account password                 | `P@ssw0rd!234`              |
| `sqlaag_name`             | string | The name of the SQL Availability Group           | `sqlaag`                    |
| `sqlcluster_name`         | string | The name of the SQL cluster                      | `sqlcluster`                |
| `tags`                    | map    | A map of tags to assign to the resources         | `{ "source": "terraform", "project": "learning", "environment": "lab" }` |

## Outputs

| Name                      | Description                                      |
|---------------------------|--------------------------------------------------|
| `vm_addc_public_name`     | The public DNS name of vm-addc                   |
| `vm_addc_public_ip`       | The public IP address of vm-addc                 |
| `vm_sqlha_output`         | Output from the vm-sqlha module, if it exists    |

## Notes

- This module assumes that the necessary resource group is already created and available.
- Ensure you replace all placeholders with your actual values.

## Contributions

Contributions are welcome. Please open an issue or submit a pull request if you have any suggestions, questions, or would like to contribute to the project.

### GNU General Public License
This script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this script. If not, see <https://www.gnu.org/licenses/>.