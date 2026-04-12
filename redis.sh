#! /bin/bash

source ./common.sh
user_auth

dnf module disable redis -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
dnf module enable redis:7 -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)

dnf install redis -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "Installed Redis"

CURR_IP=$(grep bindIp /etc/redis/redis.conf | awk '{print $2}')

if [ "$CURR_IP" == "0.0.0.0" ]; then
    echo "Bind IP is already set to 0.0.0.0"
    sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
else
    echo "taking backup of conf file"
    cp -p /etc/redis/redis.conf /etc/redis/redis.conf_$(date +%Y-%m-%d)
    sed -i 's/bindIp:.*/bindIp: 0.0.0.0/' /etc/redis/redis.conf
    sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
    echo "updated bindIp to 0.0.0.0 and protected-mode restarting the service"
    systemctl restart redis
fi

systemctl enable redis 
systemctl start redis 
systemctl status redis &> /var/log/catalogue.log_$(date +%Y-%m-%d)
validate $? "Redis is up and running"