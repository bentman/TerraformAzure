#################### DATA ####################
########## What's my IP? (from where you are running terraform)
data "http" "myip6" {
  url = "https://icanhazip.com"
}

data "http" "myip4" {
  url = "https://ipv4.icanhazip.com"
}

data "http" "jumpwin_stuff" {
  url = "https://raw.githubusercontent.com/bentman/TerraformAzure/main/content/windows/get-mystuff.ps1"
}

data "http" "jumplin_stuff" {
  url = "https://raw.githubusercontent.com/bentman/TerraformAzure/main/content/linux/get-mystuff.bash"
}
