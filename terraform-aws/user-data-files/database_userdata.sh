#!/bin/bash
# Update system packages
yum update -y

# Install MySQL
sudo yum install -y mysql-server
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Configure MySQL (e.g., create database, user, etc.)
MYSQL_ROOT_PASSWORD="password"
MYSQL_DATABASE="stockapp"
MYSQL_USER="root"

# Initialize MySQL
sudo mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"

# Create database and user
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

# Start MySQL
sudo systemctl restart mysqld
