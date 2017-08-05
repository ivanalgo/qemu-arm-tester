#!/bin/bash -x

qemu=$1
kernel=$2
rootfs=$3

${qemu} -M vexpress-a9 -kernel ${kernel}/arch/arm/boot/zImage -dtb ${kernel}/arch/arm/boot/dts/vexpress-v2p-ca9.dtb -append "console=ttyAMA0 root=/dev/mmcblk0" -sd ${rootfs} -nographic -no-reboot
