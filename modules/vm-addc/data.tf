#################### DATA ####################
##### data.tf (vm-addc) Windows Server 2022-Datacenter
data "template_file" "posh_dcpromo" {
  template = file("${path.module}/${local.scriptName}")
  # Variable input for the Install-DomainController.ps1 script
  vars = {
    domain_name         = "${var.domain_name}"
    domain_netbios_name = "${var.domain_netbios_name}"
    safemode_admin_pswd = "${var.safemode_admin_pswd}"
  }
}
