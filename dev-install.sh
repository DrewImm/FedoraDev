#!/bin/bash

##
# Created by Andrew Immerman
# 2017-11-30
#
# FedoraDev is a shell script to download and install the latest and greatest
# development tools and utilities.

##
# Compilers
#
echo "Installing gcc packages..."
dnf install -y gcc-c++ make

##
# Editors
#

# Vim
echo "Installing vim..."
dnf install vim -y

# VS Code
echo "Installing VS Code..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
dnf install code -y

##
# Package managers
#

# NodeJS
echo "Installing NodeJS";
dnf install -y npm

##
# File
#

# Filezilla
echo "Installing filezilla..."
dnf install filezilla -y

##
# Web dev
#

# NodeJS
echo "Installing NodeJS..."
curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash -
dnf install nodejs -y

# Angular
echo "Installing angular"
npm i -g typescript @angular/cli
npm i -g ng-tabber

# Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# Postgres
yum install -y postgresql postgresql-server
systemctl enable postgresql
/usr/bin/postgresql-setup --initdb

# Google Chrome
echo "Installing Google Chrome..."
cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome - \$basearch
baseurl=http://dl.google.com/linux/chrome/rpm/stable/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF
dnf install google-chrome-stable -y

# Postman
echo "Installing Postman";
cd /tmp || exit
wget -q https://dl.pstmn.io/download/latest/linux?arch=64 -O postman.tar.gz
tar -xzf postman.tar.gz
rm postman.tar.gz

if [ -d "/opt/Postman" ];then
    rm -rf /opt/Postman
fi
mv Postman /opt/Postman

if [ -L "/usr/bin/postman" ];then
    rm -f /usr/bin/postman
fi
ln -s /opt/Postman/Postman /usr/bin/postman

cat > /home/dimmerman/.local/share/applications/postman.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=postman
Icon=/opt/Postman/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOL

##
# Cleanup
#

# Done
echo "Done"
echo "Please reboot your system for changes to take effect."

exit
