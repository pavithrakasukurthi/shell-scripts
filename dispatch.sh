#! /bin/bash

source ./common.sh

user_auth

dnf install golang -y
validate $? "installed golang"

sys_user_check

app_configuration dispatch

go mod init dispatch
go get 
go build

service_file_check dispatch