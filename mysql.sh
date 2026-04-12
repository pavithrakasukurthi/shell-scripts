#! /bin/bash

source ./common.sh

user_auth

dnf list installed mysql-server &> /var/log/catalogue.log_$(date +%Y-%m-%d)
if [ $? -eq 0 ]; then
    echo "mysql already installed"
else
    dnf install mysql-server -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
    validate $? "mysql-server installed"
fi

systemctl enable mysqld
systemctl start mysqld  
systemctl status mysqld &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "mysql is up and running"

echo "setting up root password for mysql"
mysql_secure_installation --set-root-pass RoboShop@1