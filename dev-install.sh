#!/bin/bash

##
# Created by Andrew Immerman
# 2017-11-30
#
# FedoraDev is a shell script to download and install the latest and greatest
# development tools and utilities.

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
# Code utilities
#

# Doxygen
echo "Installing Doxygen...";
dnf install -y doxygen

# Sass
echo "Installing Dart-Sass";
dnf install -y rubygem-sass

##
# File
#

# Filezilla
echo "Installing filezilla..."
dnf install filezilla -y

##
# Web dev
#

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

# Lamp
echo "Installing Lamp Stack..."
dnf install -y httpd php mariadb mariadb-server
dnf install -y phpmyadmin
mkdir -p /etc/httpd/sites-enabled

cat <<EOT >> /etc/httpd/conf/httpd.conf
IncludeOptional /etc/httpd/sites-enabled/*.conf
EOT

# Lamp firewall
echo "Configuring Firewall..."
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

# Enabling httpd
echo "Enabling httpd..."
systemctl restart httpd
systemctl enable httpd

# SELinux
echo "SELinux - Setting httpd network connections"
setsebool -P httpd_can_network_connect on

# Lamp permissions
echo "Setting permissions..."
rm -rf /var/www/permissions

cat <<EOT >> /var/www/permissions
#!/bin/bash
chown \$1:apache -R /var/www/\$2;

find . -type f -exec chmod 0644 {} \;
find . -type d -exec chmod 0755 {} \;

chcon -t httpd_sys_content_t /var/www/\$2 -R;

chmod 755 /var/www/permissions;
EOT

chmod 755 /var/www/permissions;

# MariaDB
echo "Configuring MariaDB..."
systemctl start mariadb.service
systemctl enable mariadb.service

firewall-cmd --add-service=mysql
/usr/bin/mysql_secure_installation

# Xdebug
echo "Installing xdebug..."
dnf install -y php-xdebug

cat <<EOT >> /etc/php.ini

[XDebug]
xdebug.remote_enable = 1
xdebug.remote_autostart = 1
EOT

# PHPUnit
echo "Installing PHPUnit...";
dnf install -y phpunit

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
# Server administration
#

# OpenXenManager
echo "Installing OpenXenManager";
yum install -y pygtk2 gtk-vnc-python rrdtool
dnf install -y pygtk2-libglade gtk-vnc-python
pip install -y configobj

cd /tmp
git clone https://github.com/OpenXenManager/openxenmanager.git
cd openxenmanager
python setup.py install

mkdir -p /opt/openxenmanager
cp /mnt/myfiles/Scripts/bin/xencenter.png /opt/openxenmanager/icon.png

cat > /home/dimmerman/.local/share/applications/openxenmanager.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Name=XenManager
Exec=openxenmanager
Icon=/opt/openxenmanager/icon.png
Terminal=false
Type=Application
Categories=Development;
EOL

##
# Theme
#

# Arc theme
dnf install -y arc-theme

# Paper theme (icons etc)
dnf config-manager --add-repo https://download.opensuse.org/repositories/home:snwh:paper/Fedora_25/home:snwh:paper.repo
dnf install -y paper-icon-theme
dnf config-manager --add-repo https://download.opensuse.org/repositories/home:snwh:paper/Fedora_25/home:snwh:paper.repo
dnf install -y paper-gtk-theme
dnf install -y gnome-tweak-tool

##
# Cleanup
#

# Done
echo "Done"
echo "Please reboot your system for changes to take effect."

exit
