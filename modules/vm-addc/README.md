# Active Directory Domain Controller (vm-addc) Terraform Module

This Terraform module deploys an Active Directory Domain Controller (AD DC) on Azure. It creates a virtual machine, sets up necessary networking, and configures the domain controller.

## Usage

```powershell
module "vm_addc" {
  source                = "./modules/vm-addc"
  count                 = var.module_vm_addc_enable ? 1 : 0
  lab_name              = var.lab_name
  rg_location           = azurerm_resource_group.mylab.location
  rg_name               = azurerm_resource_group.mylab.name
  vm_addc_hostname      = var.vm_addc_hostname
  vm_addc_size          = var.vm_addc_size
  vm_localadmin_user    = var.vm_localadmin_user
  vm_localadmin_pswd    = var.vm_localadmin_pswd
  vm_addc_shutdown_hhmm = var.vm_addc_shutdown_hhmm
  vm_addc_shutdown_tz   = var.vm_addc_shutdown_tz
  domain_name           = var.domain_name
  domain_netbios_name   = var.domain_netbios_name
  safemode_admin_pswd   = var.safemode_admin_pswd
  vm_server_snet_id     = data.azurerm_subnet.snet_0128_server.id
  tags                  = var.tags
}
```

## Resources

The module creates the following resources:

- **Virtual Machine** (`azurerm_windows_virtual_machine.vm_addc`)
- **Public IP** (`azurerm_public_ip.vm_addc_pip`)
- **Network Interface** (`azurerm_network_interface.vm_addc_nic`)
- **Network Security Group** (`azurerm_network_security_group.nsg_server`)
- **Extensions** (`azurerm_virtual_machine_extension.vm_addc_openssh`)
- **Dev/Test Shutdown Schedule** (`azurerm_dev_test_global_vm_shutdown_schedule.vm_addc_shutdown`)

## Variables

| Name                   | Type         | Description                                                                            | Default                |
|------------------------|--------------|----------------------------------------------------------------------------------------|------------------------|
| `lab_name`             | `string`     | The name of the lab environment.                                                       | `mylab`                |
| `rg_location`          | `string`     | The Azure location for the resource group.                                             | `westus`               |
| `rg_name`              | `string`     | The name of the resource group.                                                        | `rg-mylab`             |
| `vm_addc_hostname`     | `string`     | The hostname for the AD DC VM.                                                         | `vmaddc`               |
| `vm_addc_size`         | `string`     | The size of the AD DC VM.                                                              | `Standard_D2s_v3`      |
| `vm_localadmin_user`   | `string`     | The local admin username for the VM.                                                   | `localadmin`           |
| `vm_localadmin_pswd`   | `string`     | The local admin password for the VM.                                                   | `P@ssw0rd!234`         |
| `vm_addc_shutdown_hhmm`| `string`     | The time for VM shutdown in HHMM format.                                               | `0000`                 |
| `vm_addc_shutdown_tz`  | `string`     | The time zone for VM shutdown.                                                         | `Pacific Standard Time`|
| `domain_name`          | `string`     | The domain name.                                                                       | `mylab.mytenant.onmicrosoft.com`|
| `domain_netbios_name`  | `string`     | The NetBIOS name of the domain.                                                        | `MYLAB`                |
| `safemode_admin_pswd`  | `string`     | The Safe Mode Administrator password.                                                  | `P@ssw0rd!234`         |
| `vm_server_snet_id`    | `string`     | The ID of the server subnet.                                                           | n/a                    |
| `tags`                 | `map(string)`| A map of tags to assign to resources.                                                  | `{}`                   |

## Outputs

| Name                | Description                              |
|---------------------|------------------------------------------|
| `vm_addc_public_name` | The public DNS name of vm-addc          |
| `vm_addc_public_ip`   | The public IP address of vm-addc        |
| `addc_module_vars`    | A map of all variables used by the submodule |

## Notes

- Ensure that the necessary subnet and resource group exist before applying this module.
- Make sure to replace placeholder values with your actual Azure resource details.
- This module is designed for educational purposes and may require adjustments for production use.
- Follow best practices for managing sensitive information, such as using secure storage for passwords and other secrets.

## Contributions

Contributions are welcome. Please open an issue or submit a pull request if you have any suggestions, questions, or would like to contribute to the project.

### GNU General Public License

This script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this script. If not, see <https://www.gnu.org/licenses/>.
