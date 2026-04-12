#! /bin/bash

source ./common.sh

user_auth

dnf install golang -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "installed golang"

sys_user_check

app_configuration dispatch

go mod init dispatch &> /var/log/catalogue.log_$(date +%Y-%m-%d)
go get &> /var/log/catalogue.log_$(date +%Y-%m-%d)
go build &> /var/log/catalogue.log_$(date +%Y-%m-%d)

service_file_check dispatch