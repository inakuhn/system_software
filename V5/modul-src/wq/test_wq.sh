#!/bin/sh
MODULE=wq
KO=/root/${MODULE}/${MODULE}.ko
ACCESS=/bin/access

accessNumber=0
echo $1
if [ $? -ne 1 ]; then
    echo "number"
    accessNumber=$1
    echo $accessNumber
else
    echo "not number acess wil be call with 0"
fi
echo "##############################################"
echo "#                Workqueue 1                 #"
echo "##############################################"
echo "#################Information##################"
modinfo ${KO}

echo "##################Insmod#######################"
insmod ${KO}

echo "##################Lsmod########################"
lsmod ${MODULE}

echo "##################Devices######################"
cat /proc/devices | grep -i ${MODULE}
text1="##################Acess -q "
text2=" ######################"
final=$text1$accessNumber$text2 
echo $final
if [ -f "$ACCESS" ]; then
	$ACCESS -q $accessNumber
fi
echo "##################Rmmod########################"
rmmod ${MODULE}
echo "##################Dmesg########################"
dmesg -c
