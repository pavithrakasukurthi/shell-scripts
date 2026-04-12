#! /bin/bash


source ./common.sh

user_auth


dnf module disable nginx -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "Disabled nginx default version"

dnf module enable nginx:1.24 -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "Enabled nginx-1.24"

dnf install nginx -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "Nginx 2.14 has been installed"

systemctl enable nginx 

systemctl start nginx 

systemctl status nginx &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "Nginx is up and running"


echo "removing default HTML content"
rm -rf /usr/share/nginx/html/* 

echo "downloading app code"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &> /var/log/catalogue.log_$(date +%Y-%m-%d)
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &> /var/log/catalogue.log_$(date +%Y-%m-%d)

echo "copying nginx configuration file"
cp -p /home/ec2-user/shell-scripts/nginx.conf /etc/nginx/nginx.conf

systemctl restart nginx 