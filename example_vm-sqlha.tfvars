##### vm-sqlha.tf value
vm_sqlha_size                = "Standard_D2s_v3"    // vm sqlha size
vm_sqlha_hostname            = "mysqlha"           // vm sqlha hostname, 13 character max (*01 & *02)
sqlcluster_name              = "mysqlcluster"       // vm sqlha clustername, 12 character recommended
sqlaag_name                  = "mysqlhaaoaag"       // vm sqlha clustername, 12 character recommended
sql_sysadmin_login           = "mysqllogin"           // sql sysadmin username
sql_sysadmin_password        = "P@ssword!2024"      // sql sysadmin password
sql_service_account_login    = "mysqlsvc"             // sql service username
sql_service_account_password = "P@ssword!2024"      // sql service password
vm_sqlha_image_publisher     = "MicrosoftSQLServer" // vm sqlha image publisher
vm_sqlha_image_offer         = "sql2022-ws2022"     // vm sqlha image version
vm_sqlha_image_sku           = "sqldev-gen2"        // vm sqlha image sku
sqldatafilepath              = "K:\\Data"           // vm sqlha cluster dsk data path
sqllogfilepath               = "L:\\Logs"           // vm sqlha cluster dsk logs path
sqltempfilepath              = "T:\\Temp"           // vm sqlha cluster dsk temp path
sql_image_offer              = "SQL2022-WS2022"     // azure sql image offer
sql_image_sku                = "Developer"          // azure sql image sku

