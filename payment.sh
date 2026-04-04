#! /bin/bash

source ./common.sh

user_auth 

dnf install python3 gcc python3-devel -y

sys_user_check

app_configuration payment

pip3 install -r requirements.txt
validate $? "Installed dependencies"

service_file_check payment