#################### LOCALS ####################
### Local variables for vm-addc (domain controller)
# Local variable for the DCPromo script
locals {
  dcPromoScript  = "Install-DomainController.ps1"
  addDevToServer = "Add-DevToMyWinServer.ps1"
  server_stuff   = "get-serverstuff.ps1"
}
