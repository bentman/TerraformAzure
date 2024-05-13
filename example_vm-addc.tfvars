##### vm-addc.tf value
vm_addc_size_addc   = "Standard_D2s_v3"            // vm addc size
vm_addc_hostname    = "vm-dc0150"                  // vm addc hostname, 15 character max
domain_name         = "your.fqdn.onmicrosoft.com"  // ad fqdn domain name
domain_netbios_name = "YourNetBIOSDomainName"      // ad netbios domain name
domain_admin_user   = "YourDomainAdminUserName"    // domwin admin username
domain_admin_pswd   = "YourDomainAdminPassword"    // domain admin password
safemode_admin_pswd = "YourDomainSafeModePassword" // domain safemode password
