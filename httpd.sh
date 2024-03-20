#!/bin/bash

# Install Apache HTTP Server
sudo apt update
sudo apt install -y apache2

# Define variables
domain="hala.com"
config_file="/etc/apache2/sites-available/${domain}.conf"
htaccess_file="/var/www/html/.htaccess"
username="user"
password="password"

# Create directory for website
sudo mkdir -p /var/www/${domain}/html

# Set permissions
sudo chown -R $USER:$USER /var/www/${domain}/html
sudo chmod -R 755 /var/www/${domain}

# Create a virtual host configuration file
sudo touch $config_file
sudo bash -c "cat > $config_file" <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@${domain}
    ServerName ${domain}
    ServerAlias www.${domain}
    DocumentRoot /var/www/${domain}/html

    <Directory /var/www/${domain}/html>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/${domain}_error.log
    CustomLog ${APACHE_LOG_DIR}/${domain}_access.log combined
</VirtualHost>
EOF

# Enable the virtual host
sudo a2ensite ${domain}.conf

# Restart Apache
sudo systemctl restart apache2

# Create .htaccess file with authentication
sudo bash -c "cat > $htaccess_file" <<EOF
AuthType Basic
AuthName "Restricted Access"
AuthUserFile /etc/apache2/.htpasswd
Require valid-user
EOF

# Create user for authentication
sudo htpasswd -c /etc/apache2/.htpasswd $username $password

# Reload Apache
sudo systemctl reload apache2

echo "Apache HTTP Server installed and configured."
