#!/bin/bash
# Script to install the dashboard component of the ESGF monitoring system)
# Author: CMCC (sandro.fiore@cmcc.it)
# Creation date: 20/09/2016
# Last update: 08/12/2016 by CMCC

#default values
DashDir="/usr/local/esgf-dashboard-ip"
GeoipDir="/usr/local/geoip"
Fed="no"

if [ "$1" == "-h" ]; then
    echo "*****************************************"
    echo "Installer for the ESGF Dashboard"
    echo "Author: CMCC"
    echo "*****************************************"
    echo "Usage: $0 param1 param2"
    echo "* param1: <install dir of dashboard>"
    echo "* param2: <install dir of geoip library>"
    echo "* param3: <enable the federation>"
    echo "* default values:" 
    echo "	param1=$DashDir"
    echo "	param2=$GeoipDir"
    echo "	param3=$Fed"
    echo "To run with default values:"
    echo "	./dashboard.sh"
    echo "Enjoj!"
    echo "*****************************************"
    exit 0
fi

if [ "$1" != "" ]; then
        DashDir=$1
fi
if [ "$2" != "" ]; then
        GeoipDir=$2
fi

if [ "$3" != "" ]; then
        Fed=$3
fi

cd /usr/local

git clone https://github.com/ESGF/esgf-dashboard.git

cd esgf-dashboard/

git checkout -b work_plana origin/work_plana

cd src/c/esgf-dashboard-ip

./configure --prefix=$DashDir --with-geoip-prefix-path=$GeoipDir --with-allow-federation=$Fed

make
make install

cd -
cd ..
