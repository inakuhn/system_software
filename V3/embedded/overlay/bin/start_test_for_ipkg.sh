#!/bin/busybox sh
# create ipkg and sent to rpi path
#
#
SYS=systeminfo
BASH=sysinfo

ACCESS=/bin/access
echo "##############################################"
echo "#         Start dowloag IPKG                 #"
echo "##############################################"

ipkg-cl install http://192.168.29.1:8000/syso/2/syso_systeminfo.ipkg


echo "##############################################"
echo "#         Seeing dowload from IPKG           #"
echo "##############################################"
echo "ls bin/ | grep -i systeminfo"
ls bin/ | grep -i ${SYS}
echo "ls bin/ | grep -i sysinfo"
ls etc/init.d/ | grep -i ${BASH}
echo "##############################################"
echo "#         remove dowloag IPKG                #"
echo "##############################################"

ipkg-cl remove systeminfo

echo "##############################################"
echo "# Seeing dowload from was removed IPKG       #"
echo "##############################################"
echo "ls bin/ | grep -i systeminfo"
ls bin/ | grep -i ${SYS}
echo "ls bin/ | grep -i sysinfo"
ls etc/init.d/ | grep -i ${BASH}
echo "##############################################"
echo "#           Finish Test!                     #"
echo "##############################################"
