/*#################### VALUES ####################
########## SECRET VALUES ##########
#####  Declare confidential variables here
#####  Store secret values in *.tfvars file
#####  Check .gitignore in repo for details
########## SECRET VALUES ##########
arm_tenant_id          = "YourTenantId"               // azure tenant id
arm_subscription_id    = "YourSubscriptionId"         // azure subscription id
arm_client_id          = "YourServicePrincipalId"     // azure service principal id
arm_client_secret      = "YourServicePrincipalSecret" // azure service principal secret
vm_localadmin_username = "YourAdminUsername"          // vm local admin username 'localadmin'
vm_localadmin_password = "YourAdminPassword"          // vm local admin password 'P@ssw0rd!234'

########## MODULES ##########
# RECOMMENDED: run all 'module = false' to setup root/v-network.tf
enable_module_vm_jumpbox = false
enable_module_sql_ha     = false
enable_module_dc1        = false

########## MODULE VALUES ##########
##### main.tf values
lab_name    = "mylab"  // defaults to 'mylab'
rg_location = "westus" // defaults to 'westus'
tags = {
  "source"      = "terraform"
  "project"     = "learning"
  "environment" = "lab"
}

##### vm-jumpbox module values
# vm common values
vm_size          = "Standard_D2s_v3"       // defaults to 'Standard_D2s_v3'
vm_shutdown_tz   = "Pacific Standard Time" // defaults to 'Pacific Standard Time'
vm_shutdown_hhmm = "0000"                  // defaults to '0000' - aka midnight ;-)

# vm-jumpwin (fail if not unique in public DNS)
vm_jumpwin_hostname = "jumpwin007" // defaults to 'jumpwin007'

# vm-jumplin (fail if not unique in public DNS)
vm_jumplin_hostname = "jumpwin008" // defaults to 'jumpwin008'

##### sql-ha module values
# sql-ha domain values
domain_name         = "your.onmicrosoft.com"       // ad fqdn domain name
domain_netbios_name = "YourNetBIOSDomainName"      // ad netbios domain name
domain_admin_user   = "YourDomainAdminUserName"    // domwin admin username 'domainadmin'
domain_admin_pswd   = "YourDomainAdminPassword"    // domain admin password 'P@ssw0rd!234'
safemode_admin_pswd = "YourDomainSafeModePassword" // domain safemode password

# vm-addc.tf values
vm_addc_size     = "Standard_D2s_v3" // vm addc size
vm_addc_hostname = "vm-dc0150"       // vm addc hostname, 15 character max

# vm-sqlha.tf values
vm_sqlha_size     = "Standard_D2s_v3" // vm sqlha size
vm_sqlha_hostname = "vm-mysqlha"      // vm sqlha hostname, 13 character max (*01 & *02)
sqlcluster_name   = "mysqlcluster"    // vm sqlha cluster name, 12 character recommended
sqlaag_name       = "mysqlhaaoaag"    // vm sqlha AG name, 12 character recommended
sql_svc_acct_user = "mysqlsvc"        // sql service username
sql_svc_acct_pswd = "P@ssword!2024"   // sql service password
sql_sysadmin_user = "mysqllogin"      // sql sysadmin username
sql_sysadmin_pswd = "P@ssword!2024"   // sql sysadmin password

##### vm-dc1 module values
vm_dc1_size             = "Standard_D2s_v3"               // vm dc1 size
vm_dc1_hostname         = "vm-dc170"                      // vm dc1 hostname, 15 character max
dc1_domain_name         = "anotherdomain.onmicrosoft.lan" // another fqdn domain name
dc1_domain_netbios_name = "anotherdomain"                 // another netbios domain name, 15 character max
*/
#################### NOTES ####################
# Instructions for generating a new Service Principal and Secret using PowerShell
#
# 1. Open PowerShell and run:
#    $sp = New-AzADServicePrincipal -DisplayName "Terraform" -Role "Contributor"
#    $sp.AppId 
#    $sp.PasswordCredentials.SecretText # Create Credential Secret
#
# Instructions for generating a new Service Principal and Secret using Azure CLI
#
# 1. Open a terminal and run:
#    az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<your-subscription-id>"
