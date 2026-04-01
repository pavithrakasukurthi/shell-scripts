#!/bin/bash

R="\033[31m"
G="\033[32m"
Y="\033[33m"

if [ $(id -u) -ne 0 ]; then
    echo -e "$R Execute this script with root previlages $R"
    exit 1
fi

dnf list installed mysql > /dev/null
if [ $? -eq 0 ]; then
    echo -e "$Y mysql already installed...SKIPPING INSTALLATION $Y"
    exit 1
else
    dnf install mysql -y
    echo -e "$G INSTALLATION SUCESS"
fi
