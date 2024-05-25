resource "azurerm_module" "example" {
  name                = "example-resource"
  location            = var.location
  resource_group_name = var.rg_name
}
