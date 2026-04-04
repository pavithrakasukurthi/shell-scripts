#! /bin/bash

source ./common.sh

user_auth

dnf install maven -y

sys_user_check

app_configuration shipping

mvn clean package 
mv target/shipping-1.0.jar shipping.jar 
validate $? "Renamed artifact"

service_file_check shipping


dnf install mysql -y 
validate $? "mysql installed"

mysql -h mysql.pavithra.sbs -uroot -pRoboShop@1 < /app/db/schema.sql

mysql -h mysql.pavithra.sbs -uroot -pRoboShop@1 < /app/db/app-user.sql 

mysql -h mysql.pavithra.sbs -uroot -pRoboShop@1 < /app/db/master-data.sql

systemctl restart shipping
validate $? "shipping service has been restarted"