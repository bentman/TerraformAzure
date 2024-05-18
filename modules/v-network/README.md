# Lab Network Terraform Module

This Terraform module creates a lab network in Azure, including virtual networks, subnets, public IP addresses, NAT gateways, and network security groups.

## Usage

```hcl
module "lab_network" {
  source = "path/to/this/module"

  lab_name           = "myLab"
  rg_name            = "myResourceGroup"
  rg_location        = "East US"
  tags               = {
    Environment = "Dev"
    Project     = "Lab Network"
  }
}
```

## Resources

The module creates the following resources:

- **Virtual Network** (`azurerm_virtual_network.vnet_lab`)
- **Subnets** 
  - `azurerm_subnet.snet_0000_jumpbox`
  - `azurerm_subnet.snet_0032_gateway`
  - `azurerm_subnet.snet_0064_db1`
  - `azurerm_subnet.snet_0096_db2`
  - `azurerm_subnet.snet_0128_server`
  - `azurerm_subnet.snet_1000_client`
- **Public IP Address for NAT Gateway** (`azurerm_public_ip.vnet_gw_pip`)
- **NAT Gateway** (`azurerm_nat_gateway.vnet_gw_nat`)
- **NAT Gateway Public IP Association** (`azurerm_nat_gateway_public_ip_association.vnet_gw_pip_assoc`)
- **NAT Gateway Subnet Associations**
  - `azurerm_subnet_nat_gateway_association.vnet_gw_snet_assoc_jumpbox`
  - `azurerm_subnet_nat_gateway_association.vnet_gw_snet_assoc_gateway`
  - `azurerm_subnet_nat_gateway_association.vnet_gw_snet_db1_assoc`
  - `azurerm_subnet_nat_gateway_association.vnet_gw_snet_db2_assoc`
  - `azurerm_subnet_nat_gateway_association.vnet_gw_snet_assoc_server`
  - `azurerm_subnet_nat_gateway_association.vnet_gw_snet_assoc_client`
- **Network Security Group** (`azurerm_network_security_group.vnet_nsg`)

## Variables

| Name      | Type   | Description                             | Default |
|-----------|--------|-----------------------------------------|---------|
| `lab_name` | string | The name of the lab                     | n/a     |
| `rg_name`  | string | The name of the resource group          | n/a     |
| `rg_location` | string | The location of the resource group     | n/a     |
| `tags`      | map    | A map of tags to apply to the resources | n/a     |

## Outputs

| Name                 | Description                                  |
|----------------------|----------------------------------------------|
| `lab_network_name`   | The name of the lab network                  |
| `lab_network_snet`   | The subnet configuration of the lab network  |
| `lab_network_vnet`   | The virtual network configuration of the lab |

## Notes

- This module assumes that the necessary resource group is already created and available.
- Make sure to replace placeholders with your actual values.
