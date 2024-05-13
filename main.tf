#################### MAIN ####################
########## RESOURCES
# Create Lab Resource Group
resource "azurerm_resource_group" "mylab" {
  location = var.resource_group_region
  name     = "rg-${var.lab_name}-${var.resource_group_region}"
  tags     = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

########## OUTPUTS
output "resource_group_name" {
  value = azurerm_resource_group.mylab.name
}
output "resource_group_location" {
  value = azurerm_resource_group.mylab.location
}
