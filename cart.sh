#! /bin/bash

source ./common.sh
user_auth

nodejs_installation

sys_user_check

app_configuration cart

if [ -f package.json ]; then
    echo "Installing dependencies"
    npm install &> /var/log/catalogue.log_$(date +%Y-%m-%d)
fi 

service_file_check cart