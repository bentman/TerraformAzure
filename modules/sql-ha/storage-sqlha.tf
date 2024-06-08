########## vm-sqlha cluster storage
# storage account for cloud sql-witness
resource "azurerm_storage_account" "sqlha_stga" {
  name                     = "sqlstgwitnes"
  location                 = var.rg_location
  resource_group_name      = var.rg_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# blob container cloud sql-quorum
resource "azurerm_storage_container" "sqlha_quorum" {
  name                  = "sqlstgquorum"
  storage_account_name  = azurerm_storage_account.sqlha_stga.name
  container_access_type = "private"
}
