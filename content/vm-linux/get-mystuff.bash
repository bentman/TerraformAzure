#############################################################

newUsr='bentl'
# add local user (will prompt for password)
sudo adduser $newUsr
# add local user to sudo
sudo usermod -aG sudo $newUsr
# add local user to sudo
su $newUsr
# set timezone
sudo timedatectl set-timezone America/Chicago

#############################################################

# Update Ubuntu
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt -y update
sudo apt -y install cinnamon-desktop-environment
cinnamon --version
sudo apt -y install xrdp
sudo systemctl enable xrdp
sudo adduser xrdp ssl-cert
sudo ufw allow 3389
sudo systemctl restart ufw
sudo apt install -y ubuntu-restricted-extras
sudo apt install -y --reinstall ttf-mscorefonts-installer
# now you can use rdp to connect to your linux desktop

#############################################################

# Lan IP Address (Primary NIC)
sudo apt install net-tools
ifconfig

# Disable Suspend and Hibernation
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Install prerequisites
sudo apt install -y apt-transport-https ca-certificates 
sudo apt install -y gdebi alien software-properties-common
sudo apt install -y net-tools wget curl gnupg gnupg-agent
sudo apt install -y openvpn dialog python3-pip python3-setuptools
sudo apt install -y conky conky-all

#############################################################

# Remove Games & Open Office
sudo apt remove -y --purge xscreensaver gnome-screensaver gnome-games
sudo apt remove -y --purge libreoffice-math libreoffice-writer libreoffice-impress libreoffice-draw libreoffice-calc
sudo apt remove -y --purge libreoffice-base
sudo apt autoremove -y

#############################################################

# Refresh Snap library
sudo snap refresh

# Install Snaps
sudo snap install chromium --classic
sudo snap install powershell --classic
sudo snap install code --classic
sudo snap install git-ubuntu --classic
sudo snap install remmina

# Install Azure-CLI (One-Liner)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Edge Browser (Stable)
firefox https://www.microsoft.com/en-us/edge
pushd ~/Downloads/
sudo chown 777 microsoft-edge-stable*
sudo apt install -y ./microsoft-edge-stable*.deb
rm ./microsoft-edge-stable*.deb
sudo apt-get update

# Check History and Export
echo $HISTFILE
history | cut -c 8- > ~/bash_history.txt 

#############################################################
#############################################################

# Enforce SSH
sudo apt install -y ssh
sudo systemctl start ssh
sudo ufw allow ssh
systemctl status ssh

#############################################################

pushd ~/Downloads/
# Install Teams (https://www.microsoft.com/en-us/microsoft-teams/download-app)
# sudo snap install teams-for-linux --classic
curl https://go.microsoft.com/fwlink/p/?linkid=2112886&clcid=0x409&culture=en-us&country=us
sudo apt install -y ./teams*.deb
popd

# Install Zoom
pushd ~/Downloads/
wget https://zoom.us/client/latest/zoom_amd64.deb
sudo apt --fix-broken install -y ./zoom_amd64.deb
sudo apt-get update
popd

# Install ProtonVPN
pushd ~/Downloads/
wget https://protonvpn.com/download/protonvpn-stable-release_1.0.1-1_all.deb
sudo apt install -y ./protonvpn-stable-release_1.0.1-1_all.deb
sudo apt install -y protonvpn protonvpn-cli
protonvpn-cli --help
protonvpn-cli login bmwcell
protonvpn-cli config --vpn-accelerator --help
protonvpn-cli c -f
popd

# Install Docker.io
sudo apt install -y docker.io
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER
# reboot

# Install Bitwarden (.appimage)
https://bitwarden.com/download/

# Refresh Snap library
sudo snap refresh
