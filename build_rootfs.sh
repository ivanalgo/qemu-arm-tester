#!/bin/bash

uid=$(id -u)
if [ $uid -ne 0 ]; then
	echo "please run as root or sudo" 1>&2
	exit 1
fi

if [ ! -e busybox-1.20.2.tar.bz2 ]; then
	wget --no-check-certificate http://www.busybox.net/downloads/busybox-1.20.2.tar.bz2  || 
	(echo "Download busybox error" && exit 1)
fi

if [ ! -e busybox-1.20.2 ]; then
	tar jxf busybox-1.20.2.tar.bz2
fi

if [ ! -e busybox-1.20.2/_install/linuxrc ]; then
	cd busybox-1.20.2
	make defconfig
	make CROSS_COMPILE=arm-linux-gnueabi-
	make install CROSS_COMPILE=arm-linux-gnueabi-
	cd ..
fi

mkdir -p rootfs/{dev,etc/init.d,lib}
cp busybox-1.20.2/_install/* -r rootfs/
cp -P /usr/arm-linux-gnueabi/lib/* rootfs/lib/
mknod rootfs/dev/tty1 c 4 1
mknod rootfs/dev/tty2 c 4 2
mknod rootfs/dev/tty3 c 4 3
mknod rootfs/dev/tty4 c 4 4

cat > rootfs/etc/init.d/rcS <<EOF
mkdir /proc
mount -t proc nodev /proc
reboot
EOF

chmod a+x rootfs/etc/init.d/rcS

dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=32
yes | mkfs.ext3 a9rootfs.ext3

if [ ! -d tmpfs ]; then
	mkdir tmpfs
fi

mount -t ext3 a9rootfs.ext3 tmpfs/ -o loop
cp -r rootfs/*  tmpfs/
umount tmpfs
