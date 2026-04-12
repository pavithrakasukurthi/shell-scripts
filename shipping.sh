#! /bin/bash

source ./common.sh

user_auth

dnf install maven -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)

sys_user_check

app_configuration shipping

mvn clean package &> /var/log/catalogue.log_$(date +%Y-%m-%d)
mv target/shipping-1.0.jar shipping.jar 
validate $? "Renamed artifact"

service_file_check shipping


dnf install mysql -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "mysql installed"

mysql -h mysql.pavithra.sbs -uroot -pRoboShop@1 < /app/db/schema.sql &> /var/log/catalogue.log_$(date +%Y-%m-%d)

mysql -h mysql.pavithra.sbs -uroot -pRoboShop@1 < /app/db/app-user.sql &> /var/log/catalogue.log_$(date +%Y-%m-%d)

mysql -h mysql.pavithra.sbs -uroot -pRoboShop@1 < /app/db/master-data.sql &> /var/log/catalogue.log_$(date +%Y-%m-%d)

systemctl restart shipping
validate $? "shipping service has been restarted"