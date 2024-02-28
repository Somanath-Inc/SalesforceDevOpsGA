#This script Compares all the files between two branches

if [ $# -ne 2 ];
then
    echo "Please Input the file Names"
    exit 1
fi

file1=$1
file2=$2

diff -u $file1 $file2 > file1.xml
