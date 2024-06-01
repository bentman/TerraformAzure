# Create NSG Jumpbox
resource "azurerm_network_security_group" "nsg_jumpbox" {
  name                = "vnet-nsg-jumpbox"
  location            = var.rg_location
  resource_group_name = var.rg_name
  tags                = var.tags
  # nsg-jumpbox to allow SSH
  security_rule {
    name                       = "vnet-nsg-jumpbox-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # nsg-jumpbox to allow RDP
  security_rule {
    name                       = "vnet-nsg-jumpbox-RDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  /*# nsg-jumpbox to allow WinRM
  security_rule {
    name                       = "vnet-nsg-jumpbox-WinRM"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }*/
  # nsg-jumpbox to allow ping
  security_rule {
    name                       = "vnet-nsg-jumpbox-ping"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # nsg-jumpbox to allow ALL
  security_rule {
    name                       = "vnet-nsg-jumpbox-local-all"
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
