NUM=$1
R="\e[31m"

if [ $NUM -eq 0 ]; then
    echo -e "$R $NUM is Zero"
else
    echo "$NUM is not zero
fi