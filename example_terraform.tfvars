// Specify confidential variable values below here

// azure tenant id
ARM_TENANT_ID = "YourTenantId"
// azure subscription id
ARM_SUBSCRIPTION_ID = "YourSubscriptionId"
// terraform client id
ARM_CLIENT_ID = "YourServicePrincipleId"
// terraform client secret
ARM_CLIENT_SECRET = "YourServicePrincipleSecret"

// admin password
ADMIN_USER = "YourAdminUserName"
ADMIN_PSWD = "YourAdminPassword"

// sql random password
SQL_ADMIN_USER = "YourSqlAdminUserName"

/* How to generate a new Service Principle and Secret using PowershellAzAD
// ARM_APP_ID_NAME="Terraform"
$sp = New-AzADServicePrincipal -DisplayName "Terraform" -Role "Contributor"
$sp.AppId 
$sp.PasswordCredentials.SecretText # Create Credential Secret
*/

/* How to generate a new Service Principle and Secret using AZ AD SP
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$($myAzSubscriptionID)"
*/
