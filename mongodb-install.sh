#! /bin/bash

CURR_IP=$(grep bindIp /etc/mongod.conf | awk '{print $2}')

# checking if user has root previlages

if [ $(id -u) -ne 0 ]; then
    echo "Run with root previlages"
fi

#adding mongo repo

echo "creating mongo repo..."

if [ -f /etc/yum.repos.d/mongo.repo ]; then
    echo "Mongo repo already exists"
else
    cat <<EOF > /etc/yum.repos.d/mongo.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/
enabled=1
gpgcheck=0
EOF
fi

#check if mongodb is installed, install if not installed.

dnf list installed mongodb &> /var/log/mongodb.log_$(date +%Y-%m-%d)

if [ $? -ne 0 ]; then
    dnf install mongodb-org -y &> /var/log/mongodb.log_$(date +%Y-%m-%d)
else
    echo "mongodb already installed...Skipping installation"
    echo "Starting and enabling mongodb"
    systemctl start mongod
    systemctl enable mongod
fi 

#checking binding IP of mongodb and changing it to 0.0.0.0

if [ "$CURR_IP" == "0.0.0.0" ]; then
    echo "Bind IP is already set to 0.0.0.0"
else
    echo "taking backup of conf file"
    cp -p /etc/mongod.conf /etc/mongod.conf_$(date +%Y-%m-%d)
    sed -i 's/bindIp: */bindIp: 0.0.0.0/' /etc/mongod.conf
    echo "updated bindIp to 0.0.0.0 and restarting the service"
    systemctl restart mongod
fi

# checking if the service is active and running

systemctl status mongod &> /var/log/mongodb.log_$(date +%Y-%m-%d)

if [ $? -eq 0 ]; then
    echo "Mongodb is active and running"
else
    echo "Mongodb is not running"
fi











