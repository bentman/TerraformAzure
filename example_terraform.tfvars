#################### VALUES ####################
########## SECRET VALUES ##########
#####  Declare confidential variables here
#####  Store secret values in *.tfvars file
#####  Check .gitingnore in repo for details
########## SECRET VALUES ##########
arm_tenant_id          = "YourTenantId"               // azure tenant id
arm_subscription_id    = "YourSubscriptionId"         // azure subscription id
arm_client_id          = "YourServicePrincipleId"     // azure service principle id
arm_client_secret      = "YourServicePrincipleSecret" // azure service principle secret
vm_localadmin_username = "YourAdminUsername"          // vm local admin username
vm_localadmin_password = "YourAdminPassword"          // vm local admin password

########## NON-DEFAULT VALUES ##########
##### main.tf values
lab_name              = "mylab"                 // defaults to 'mylab'
resource_group_region = "westus"                // defaults to 'westus'
vm_shutdown_hhmm      = "0000"                  // defaults to '0000' - aka midnight ;-)
vm_shutdown_tz        = "Pacific Standard Time" // defaults to 'Pacific Standard Time'

# vm common values
vm_size = "Standard_D2s_v3" // defaults to 'Standard_D2s_v3'

/*#################### NOTES ####################
How to generate a new Service Principle and Secret using PowershellAzAD

$sp = New-AzADServicePrincipal -DisplayName "Terraform" -Role "Contributor"
$sp.AppId 
$sp.PasswordCredentials.SecretText # Create Credential Secret

How to generate a new Service Principle and Secret using AZ AD SP

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$($myAzSubscriptionID)"
*/
