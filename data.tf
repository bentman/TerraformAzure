#################### DATA ####################
##### What's my IP? (from where you are running terraform)
data "http" "myip6" {
  url = "https://icanhazip.com"
}

data "http" "myip4" {
  url = "https://ipv4.icanhazip.com"
}

##### reference to jumpbox scripts (file-copy from repo, soon)
data "http" "jumpwin_stuff" {
  url = "https://raw.githubusercontent.com/bentman/TerraformAzure/main/content/windows/get-mystuff.ps1"
}

data "http" "jumplin_stuff" {
  url = "https://raw.githubusercontent.com/bentman/TerraformAzure/main/content/linux/get-mystuff.bash"
}

##### data from main.tf
data "azurerm_resource_group" "mylab" {
  name       = "rg-${var.lab_name}-${var.rg_location}"
  depends_on = [azurerm_resource_group.mylab]
}

##### data from v-network.tf
data "azurerm_virtual_network" "azurerm_virtual_network" {
  name                = "net-0.000-${var.lab_name}"
  resource_group_name = data.azurerm_resource_group.mylab.name
  depends_on          = [data.azurerm_resource_group.mylab, module.v_network]
}

data "azurerm_subnet" "snet_0000_jumpbox" {
  name                 = "snet-0.000-jumpbox"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on          = [module.v_network]
}

data "azurerm_subnet" "snet_0032_gateway" {
  name                 = "snet-0.032-gateway"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on          = [module.v_network]
}

data "azurerm_subnet" "snet_0064_db1" {
  name                 = "snet-0.064-db1"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on          = [module.v_network]
}

data "azurerm_subnet" "snet_0096_db2" {
  name                 = "snet-0.096-db2"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on          = [module.v_network]
}

data "azurerm_subnet" "snet_0128_server" {
  name                 = "snet-0.128-server"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on          = [module.v_network]
}

data "azurerm_subnet" "snet_1000_client" {
  name                 = "snet-1.000-client"
  virtual_network_name = data.azurerm_virtual_network.azurerm_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.mylab.name
  depends_on          = [module.v_network]
}
