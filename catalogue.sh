#! /bin/bash

# checking is the script is run by root user

if [ $(id -u) -ne 0 ]; then
    echo "Run with root previlages"
    exit 1
fi


dnf list installed nodejs &> /var/log/catalogue.log_$(date +%Y-%m-%d)

if [ $? -eq 0 ]; then
    echo "nodejs already installed, checking version..."
    if [ "$(node -v|awk -F '.' "{print $1}")" -eq "v20" ]; then
        echo "Node js version 20 is already installed, skipping installtion..."
    else
       echo "removing existing version and installing required version"
        dnf remove nodejs -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
        dnf module disable nodejs -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
        dnf module enable nodejs:20 -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
        dnf install nodejs -y &> /var/log/catalogue.log_$(date +%Y-%m-%d) 
    fi
fi 

#dadding systemc user and ownloading app code
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
mkdir /app
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &> /var/log/catalogue.log_$(date +%Y-%m-%d)
cd /app 
unzip /tmp/catalogue.zip &> /var/log/catalogue.log_$(date +%Y-%m-%d)

 if [ -f package.json ]; then
    echo "Installing dependencies"
    npm install &> /var/log/catalogue.log_$(date +%Y-%m-%d)
fi

#setting up systemd service

if [ -f /etc/systemd/system/catalogue.service ]; then
    echo "service file exists"
else
    cat <<EOF > /etc/systemd/system/catalogue.service
[Unit]
Description = Catalogue Service

[Service]
User=roboshop
Environment=MONGO=true
// highlight-start
Environment=MONGO_URL="mongodb://mongodb.pavithra.sbs:27017/catalogue"
// highlight-end
ExecStart=/bin/node /app/server.js
SyslogIdentifier=catalogue

[Install]
WantedBy=multi-user.target
EOF
fi

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
systemctl status catalogue &> /var/log/catalogue.log_$(date +%Y-%m-%d)

if [ $? -eq 0 ]; then
    echo "Catalogue is up and running"
else
    "Catalogue is not running"
    exit 1
fi 

#adding mongo repo

echo "creating mongo repo..."

if [ -f /etc/yum.repos.d/mongo.repo ]; then
    echo "Mongo repo already exists"
    exit 1
else
    cat <<EOF > /etc/yum.repos.d/mongo.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/
enabled=1
gpgcheck=0
EOF
fi

dnf install mongodb-mongosh -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)

if [ $? -eq 0 ]; then
    echo "mongosh installed, running script in mongo server"
    mongosh --host mongodb.pavithra.sbs </app/db/master-data.js
    mongosh --host mongodb.pavithra.sbs
    if [ $? -eq 0 ]; then
        show dbs
        use catalogue
        if [ $? -eq 0 ]; then
            show collections
            db.products.find()
        fi
    fi
else
    echo "mongosh installtion failed"
fi









    






