#! /bin/bash

source ./common.sh

user_auth 

dnf install python3 gcc python3-devel -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)

sys_user_check

app_configuration payment

pip3 install -r requirements.txt &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "Installed dependencies"

service_file_check payment