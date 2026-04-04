#! /bin/bash

source ./common.sh

user_auth

create_repo rabbitmq

dnf install rabbitmq-server -y
validate $? "rabbitmq installed"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
systemctl status rabbitmq-server
validate $? "Rabbitmq is up and running"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"