data "template_file" "dc_promo" {
  template = "${file("${path.module}/Install-DomainController.ps1")}"
  vars = {
    domain_name           = var.domain_name
    domain_netbios_name   = var.domain_netbios_name
    safemode_admin_pswd   = var.safemode_admin_pswd
  }
} 
