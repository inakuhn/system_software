#!/bin/sh
# create ipkg and sent to rpi path
#
#
echo "##############################################"
echo "#  Delete Create and Copy IPKG TO SYSO/2     #"
echo "##############################################"
MAIN_DIR_PATH=$(pwd)
RPI_PATH="/srv/http/syso/2/syso_systeminfo.ipkg"
IPKG_PACKAGE="ipkg-package"
IPKG_NAME="systeminfo_1.0_arm.ipk"
echo "##############################################"
echo "#  Delete    systeminfo_1.0_arm              #"
echo "##############################################"
rm -rf $IPKG_NAME
echo "##############################################"
echo "#  Create new    systeminfo_1.0_arm          #"
echo "##############################################"
sh ipkg-build.sh $IPKG_PACKAGE
echo "##############################################"
echo "#  Copy to syso/2   systeminfo_1.0_arm       #"
echo "##############################################"
cp $IPKG_NAME $RPI_PATH
rm -rf $IPKG_NAME

