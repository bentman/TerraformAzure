#################### LOCALS ####################
##### locals.tf (vm-addc) Windows Server 2022-Datacenter
locals {
  # execute script to install first domain controller in active directory forest
  scriptName     = "Install-DomainController.ps1"
  scriptRendered = filebase64("${path.module}/${local.scriptName}")
  # use templatefile() to parse script parameters
  ifTemplateFile = base64encode(templatefile("${path.module}/${local.scriptName}", {}))
  posh_dcpromo = jsonencode({
    commandToExecute = "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${local.scriptRendered}')) | Out-File -filepath ${local.scriptName}\" && powershell -ExecutionPolicy Unrestricted -File ${local.scriptName}"
  })
  # PoSh command to restart over SSH 
  restart6             = "Restart-Computer -Force"
  posh_dcpromo_restart = local.restart6
}

/* # posh script variables
-domain_name ${var.domain_name} -domain_netbios_name ${var.domain_netbios_name} -safemode_admin_pswd ${var.safemode_admin_pswd}
*/