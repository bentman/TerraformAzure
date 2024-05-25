#################### DATA ####################

##### What's my IP? (from where you are running terraform)
# Fetches the public IPv6 address
data "http" "myip6" {
  url = "https://icanhazip.com"
}

# Fetches the public IPv4 address
data "http" "myip4" {
  url = "https://ipv4.icanhazip.com"
}

##### Reference to jumpbox scripts (file-copy from repo, soon)
# Fetches the Windows jumpbox script from the repository
data "http" "jumpwin_stuff" {
  url = "https://raw.githubusercontent.com/bentman/TerraformAzure/main/modules/vm-jumpbox/vm-windows/get-mystuff.ps1"
}

# Fetches the Linux jumpbox script from the repository
data "http" "jumplin_stuff" {
  url = "https://raw.githubusercontent.com/bentman/TerraformAzure/main/modules/vm-jumpbox/vm-linux/get-mystuff.bash"
}

##### Data from main.tf
# References the resource group created in main.tf
data "azurerm_resource_group" "mylab" {
  name       = "rg-${var.lab_name}-${var.rg_location}"
  depends_on = [azurerm_resource_group.mylab]
}

##### Data from v-network.tf
# References the virtual network created in v-network.tf
data "azurerm_virtual_network" "azurerm_virtual_network" {
  name                = "net-0.000-${var.lab_name}"
  resource_group_name = data.azurerm_resource_group.mylab.name
  depends_on          = [data.azurerm_resource_group.mylab, module.v_network]
}

# References the jumpbox subnet within the virtual network
data "azurerm_subnet" "snet_0000_jumpbox" {
  name                 = "snet-0.000-jumpbox"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on           = [module.v_network]
}

# References the gateway subnet within the virtual network
data "azurerm_subnet" "snet_0032_gateway" {
  name                 = "snet-0.032-gateway"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on           = [module.v_network]
}

# References the first database subnet within the virtual network
data "azurerm_subnet" "snet_0064_db1" {
  name                 = "snet-0.064-db1"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on           = [module.v_network]
}

# References the second database subnet within the virtual network
data "azurerm_subnet" "snet_0096_db2" {
  name                 = "snet-0.096-db2"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on           = [module.v_network]
}

# References the server subnet within the virtual network
data "azurerm_subnet" "snet_0128_server" {
  name                 = "snet-0.128-server"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on           = [module.v_network]
}

# References the client subnet within the virtual network
data "azurerm_subnet" "snet_1000_client" {
  name                 = "snet-1.000-client"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on           = [module.v_network]
}
