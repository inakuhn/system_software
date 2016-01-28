#!/bin/sh
MODULE=mynull
KO=/root/${MODULE}/${MODULE}.ko
ACCESS=/bin/access

#!/bin/sh
MODULE=openclose
KO=/root/${MODULE}/${MODULE}.ko
ACCESS=/bin/access

echo "#################################################"
echo "#                Template                       #"
echo "#################################################"
echo "#################Information#####################"
modinfo ${KO}
dmesg -c > /dev/null

echo "##################Insmod#########################"
insmod ${KO}

echo "##################Lsmod##########################"
lsmod ${MODULE}

echo "##################Devices########################"
cat /proc/devices | grep -i ${MODULE}


if [ -f "$ACCESS" ]; then

prinf "\n##################Acces -W ######################\n"
  $ACCESS -w
  
printf "\n###############Acces -W -D 5 ####################\n"
  $ACCESS -w -d 5 
  
fi

printf "\n##################Rmmod##########################\n"
rmmod ${MODULE}

echo "##################Dmesg##########################"
dmesg -c

