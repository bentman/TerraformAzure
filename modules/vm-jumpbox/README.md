# vm-jumpbox Terraform Module

This Terraform module deploys Windows and Linux Jumpbox virtual machines in Azure. The module creates public IP addresses, network interfaces, virtual machines, and associated resources for both Windows and Linux VMs. 

## Usage

```hcl
module "vm_jumpbox" {
  source = "path/to/this/module"
  lab_name            = var.lab_name
  rg_location         = azurerm_resource_group.mylab.location
  rg_name             = azurerm_resource_group.mylab.name
  vm_snet_id          = data.azurerm_subnet.snet_jumpbox.id
  vm_localadmin_user  = var.vm_localadmin_user
  vm_localadmin_pswd  = var.vm_localadmin_pswd
  vm_jumpwin_hostname = "win-hostname"
  vm_jumplin_hostname = "lin-hostname"
  vm_size             = "Standard_DS1_v2"
  vm_localadmin_user  = "adminuser"code
  vm_localadmin_pswd  = "your-password"
  vm_shutdown_hhmm    = "1900"
  vm_shutdown_tz      = "Pacific Standard Time"
  tags = {
    Environment = "Dev"
    Project     = "Jumpbox"
  }
}
```

## Resources

The module creates the following resources:

- **Public IP Address for Windows Jumpbox** (`azurerm_public_ip.vm_jumpwin_pip`)
- **Network Interface for Windows Jumpbox** (`azurerm_network_interface.vm_jumpwin_nic`)
- **Windows Virtual Machine Jumpbox** (`azurerm_windows_virtual_machine.vm_jumpwin`)
- **Network Interface Security Group Association for Windows Jumpbox** (`azurerm_network_interface_security_group_association.vm_jumpwin_nsg_assoc`)
- **VM Extension to Open SSH on Windows Jumpbox** (`azurerm_virtual_machine_extension.vm_jumpwin_openssh`)
- **Auto Shutdown Schedule for Windows Jumpbox** (`azurerm_dev_test_global_vm_shutdown_schedule.vm_jumpwin_shutdown`)
- **Public IP Address for Linux Jumpbox** (`azurerm_public_ip.vm_jumplin_pip`)
- **Network Interface for Linux Jumpbox** (`azurerm_network_interface.vm_jumplin_nic`)
- **Linux Virtual Machine Jumpbox** (`azurerm_linux_virtual_machine.vm_jumplin`)
- **Network Interface Security Group Association for Linux Jumpbox** (`azurerm_network_interface_security_group_association.vm_jumplin_nsg_assoc`)
- **Auto Shutdown Schedule for Linux Jumpbox** (`azurerm_dev_test_global_vm_shutdown_schedule.vm_jumplin_shutdown`)

## Variables

| Name                     | Type   | Description                                          | Default |
|--------------------------|--------|------------------------------------------------------|---------|
| `vm_jumpwin_hostname`    | string | The hostname for the Windows Jumpbox                 | n/a     |
| `vm_jumplin_hostname`    | string | The hostname for the Linux Jumpbox                   | n/a     |
| `vm_size`                | string | The size of the virtual machines                     | n/a     |
| `vm_localadmin_user` | string | The local admin username for the virtual machines    | n/a     |
| `vm_localadmin_pswd` | string | The local admin password for the virtual machines    | n/a     |
| `vm_shutdown_hhmm`       | string | The daily auto shutdown time in HHMM format          | n/a     |
| `vm_shutdown_tz`         | string | The timezone for the auto shutdown                   | n/a     |
| `tags`                   | map    | A map of tags to apply to the resources              | n/a     |

## Outputs

| Name                 | Description                                  |
|----------------------|----------------------------------------------|
| `lab_network_name`   | The name of the lab network                  |
| `lab_network_snet`   | The subnet configuration of the lab network  |
| `lab_network_vnet`   | The virtual network configuration of the lab |

## Notes

- This module assumes that the necessary resource group and network security group are already created and available.
- Make sure to replace placeholders with your actual values.

