#!/bin/bash

if [ $UID -ne 0 ]; then
	echo "Please run as root" 1>&2
	exit 1
fi

apt-get install gcc-arm-linux-gnueabi
apt-get install zlib1g-dev
apt-get install libglib2.0-dev
