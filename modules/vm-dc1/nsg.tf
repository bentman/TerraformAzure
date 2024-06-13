########## Create NSG for vm-dc1 (& other servers)
resource "azurerm_network_security_group" "nsg_dc1" {
  name                = "vnet-nsg-dc1"
  location            = var.rg_location
  resource_group_name = var.rg_name
  tags                = var.tags
  # NSG rule to allow SSH
  security_rule {
    name                       = "vnet-nsg-dc1-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # NSG rule to allow RDP
  security_rule {
    name                       = "vnet-nsg-dc1-RDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # NSG rule to allow ping
  security_rule {
    name                       = "vnet-nsg-dc1-ping"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # NSG rule to allow all internal traffic
  security_rule {
    name                       = "vnet-nsg-dc1-local-all"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/23"
    destination_address_prefix = "*"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}
