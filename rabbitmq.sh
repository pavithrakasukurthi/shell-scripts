#! /bin/bash

source ./common.sh

user_auth

create_repo rabbitmq

dnf install rabbitmq-server -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "rabbitmq installed"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
systemctl status rabbitmq-server &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "Rabbitmq is up and running"

echo "creating rabbit user unlike app user..."
rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate $? "Permissions have been set"