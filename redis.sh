#! /bin/bash

source ./common.sh
user_auth

dnf module disable redis -y
dnf module enable redis:7 -y

dnf install redis -y 
validate $? "Installed Redis"

CURR_IP=$(grep bindIp /etc/redis/redis.conf | awk '{print $2}')

if [ "$CURR_IP" == "0.0.0.0" ]; then
    echo "Bind IP is already set to 0.0.0.0"
    sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
else
    echo "taking backup of conf file"
    cp -p /etc/mongod.conf /etc/mongod.conf_$(date +%Y-%m-%d)
    sed -i 's/bindIp: */bindIp: 0.0.0.0/' /etc/mongod.conf
    sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
    echo "updated bindIp to 0.0.0.0 and protected-mode restarting the service"
    systemctl restart mongod
fi

systemctl enable redis 
systemctl start redis 
systemctl status redis
validate $? "Redis is up and running"