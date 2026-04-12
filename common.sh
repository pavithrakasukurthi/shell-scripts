#! /bin/bash

#function to check if the user running the script is root
user_auth(){
    echo "Checking requirements to run the script"
    if [ $(id -u) -ne 0 ]; then
        echo "Run with root previlages"
        exit 1
    fi 
}

#function to if the last command executed successfully
validate(){
    echo "validating..."
    if [ $1 -eq 0 ]; then
        echo "$2"
    else
        echo "Failed"
        exit 1
    fi 
}

#function to check nodejs installtion and install it if not already installed
nodejs_installation(){
    echo "installing nodejs"
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
    else
        dnf module disable nodejs -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
        dnf module enable nodejs:20 -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
        dnf install nodejs -y &> /var/log/catalogue.log_$(date +%Y-%m-%d) 
    fi 
}

#function for app configuration
app_configuration(){
    SERVICE_NAME=$1
    echo "configuring app"
    if [ -d /app ]; then
        echo "/app already exists...SKIPPING CREATION!"
    else
        echo "creating /app"
        mkdir /app
    fi 
    curl -o /tmp/"$SERVICE_NAME".zip https://roboshop-artifacts.s3.amazonaws.com/"$SERVICE_NAME"-v3.zip &> /dev/null
    cd /app 
    unzip /tmp/"$SERVICE_NAME".zip &> /dev/null
}

#function to check if system user already exists and create one if not.
sys_user_check(){
    echo "validating system user configuration"
    id roboshop &> /dev/null
    if [ $? -eq 0 ]; then
        echo "system user already exists, skipping..."
    else
        echo "Creating System User"
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    fi
}

#function to check if service file already exists and create one if not
service_file_check(){
    SERVICE_NAME=$1
    echo "checking for service file"
    if [ -f /etc/systemd/system/"$1".service ]; then
        echo "$1 service file exists"
        echo "Reloading and enabling $1 service"
        systemctl daemon-reload
        systemctl enable $1 
        systemctl start $1
        systemctl status $1 &> /var/log/catalogue.log_$(date +%Y-%m-%d)
        validate $? "$1 is up and running"

    else
        echo "creating $1 service file..."
        cp -p /home/ec2-user/shell-scripts/"$1.service" /etc/systemd/system/"$1.service"
        validate $? "$1 Service file copied"

        systemctl daemon-reload
        systemctl enable $1 
        systemctl start $1
        systemctl status $1 &> /var/log/catalogue.log_$(date +%Y-%m-%d)
        validate $? "$1 is up and running"

    fi
}

#function to create mongo repo
create_repo(){
     repo_name=$1
     
    echo "creating $repo_name repo"
    if [ -f /etc/yum.repos.d/"$repo_name.repo" ]; then
        echo "Mongo repo already exists"
    else
        cp -p "$repo_name.repo" /etc/yum.repos.d/"$repo_name.repo"
        validate $? "$repo_name repo created"
    fi
}

#function to install mongodb
install_mongodb(){
    echo "checking mongodb installation status"
    dnf list installed mongodb &> /var/log/mongodb.log_$(date +%Y-%m-%d)

    if [ $? -ne 0 ]; then
        echo "Installing mongodb..."
        dnf install mongodb-org -y &> /var/log/mongodb.log_$(date +%Y-%m-%d)
        validate $? "Mongdb installed"
        echo "Starting and enabling mongodb"
        systemctl start mongod
        systemctl enable mongod
    else
        echo "mongodb already installed...Skipping installation"
        echo "Starting and enabling mongodb"
        systemctl start mongod
        systemctl enable mongod
    fi 
}

#function to install mongosh
install_mongo_client(){

    echo "checking mongo client installation status"
    dnf list installed mongodb-mongosh &> /var/log/catalogue.log_$(date +%Y-%m-%d)

    if [ $? -eq 0 ]; then
        echo "mongosh already installed, running script in mongo server"
        mongosh --quiet --host mongodb.pavithra.sbs </app/db/master-data.js
        mongosh --quiet --host mongodb.pavithra.sbs --eval "show dbs"
        mongosh --quiet --host mongodb.pavithra.sbs --eval "use catalogue; show collections"
        mongosh --quiet --host mongodb.pavithra.sbs --eval "db.products.find().limit(5)"
    else
        echo "Installing mongodb-mongosh"
        dnf install mongodb-mongosh -y &> /var/log/catalogue.log_$(date +%Y-%m-%d)
        validate $? "mongosh installed successfully, running script in mongo server"
        mongosh --quiet --host mongodb.pavithra.sbs </app/db/master-data.js
        mongosh --quiet --host mongodb.pavithra.sbs --eval "show dbs"
        mongosh --quiet --host mongodb.pavithra.sbs --eval "use catalogue; show collections"
        mongosh --quiet --host mongodb.pavithra.sbs --eval "db.products.find().limit(5)"
    fi
}

