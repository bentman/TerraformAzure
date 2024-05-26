#################### OUTPUTS ####################
output "vm_sqlha" {
  value = {
    for i in range(var.vm_sqlha_count) : i => {
      pip  = azurerm_public_ip.vm_sqlha_pip[i].ip_address
      name = azurerm_windows_virtual_machine.vm_sqlha[i].computer_name
    }
  }
}
