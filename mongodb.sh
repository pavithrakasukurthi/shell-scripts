#! /bin/bash

source ./common.sh
# checking is the script is run by root user
user_auth

#adding mongo repo
create_repo mongo

#check if mongodb is installed, install if not installed.
install_mongodb

#checking binding IP of mongodb and changing it to 0.0.0.0

CURR_IP=$(grep bindIp /etc/mongod.conf | awk '{print $2}')

if [ "$CURR_IP" == "0.0.0.0" ]; then
    echo "Bind IP is already set to 0.0.0.0"
else
    echo "taking backup of conf file"
    cp -p /etc/mongod.conf /etc/mongod.conf_$(date +%Y-%m-%d)
    sed -i 's/bindIp:.*/bindIp: 0.0.0.0/' /etc/mongod.conf
    echo "updated bindIp to 0.0.0.0 and restarting the service"
    systemctl restart mongod
fi

# checking if the service is active and running
echo "Checking mongodb status"
systemctl status mongod &> /var/log/mongodb.log_$(date +%Y-%m-%d)
validate $? "Mongodb is up and running"









