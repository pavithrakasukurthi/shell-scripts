#! /bin/bash

source ./common.sh

# checking is the script is run by root user
user_auth

#installing nodejs
nodejs_installation

#creating system user
sys_user_check

#setting up app dir and downloading app code
app_configuration catalogue

#installing dependencies
if [ -f package.json ]; then
    echo "Installing dependencies"
    npm install &> /var/log/catalogue.log_$(date +%Y-%m-%d)
fi

#creating catalogue service file and daemon-reloading, starting and enabling catalogue service
service_file_check catalogue

#installing mongosh, loading content to the mongo server via client and validating
install_mongo_client













    






