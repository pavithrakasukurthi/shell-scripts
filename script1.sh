#! /bin/bash

NUM=$1
R="\033[31m"
G="\033[33m"

if [ $NUM -eq 0 ]; then
    echo -e "$R$NUM is Zero"
else
    echo -e "$G$NUM is not zero"
fi