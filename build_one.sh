#!/bin/bash


#################
#
# build_one.sh  <qemu-version> <kernel-version>

QEMU_v=$1
KERNEL_v=$2

QEMU_DIR=qemu-${QEMU_v}
QEMU_COMPRESS_FILE=${QEMU_DIR}.tar.bz2
QEMU_URL=https://download.qemu.org/${QEMU_COMPRESS_FILE}
KERNEL_DIR=linux-${KERNEL_v}
KERNEL_COMPRESS_FILE=${KERNEL_DIR}.tar.gz
KERNEL_URL=https://www.kernel.org/pub/linux/kernel/v4.x/${KERNEL_COMPRESS_FILE}

echo "qemu = ${QEMU_v} kernel = ${KERNEL_v}"

WGET="wget --no-check-certificate"
CPUS=$(cat /proc/cpuinfo  | grep processor | wc -l)
MAKE="make -j$CPUS"
QEMU="qemu-${QEMU_v}/arm-softmmu/qemu-system-arm -nographic -no-reboot"

function exec_cmd()
{
	local cmd=$@

	echo ================ $cmd =================
	eval "$cmd"

	if [ $? -ne 0 ]; then
		echo ========== return $? ===========
		exit $?
	fi	
}

function download()
{
	if [ ! -e ${QEMU_COMPRESS_FILE} ]; then
		$WGET ${QEMU_URL}
	fi

	if [ ! -e ${KERNEL_COMPRESS_FILE} ]; then
		$WGET ${KERNEL_URL}
	fi
}


function extrace()
{
	if [ ! -e ${QEMU_DIR} ]; then
		tar jxf ${QEMU_COMPRESS_FILE}
	fi

	if [ ! -e ${KERNEL_DIR} ]; then
		tar zxf ${KERNEL_COMPRESS_FILE}
	fi
}

function build_qemu()
{
	if [ -e ${QEMU_DIR}/arm-softmmu/qemu-system-arm ]; then
		return
	fi

	cd ${QEMU_DIR}
	./configure --target-list=arm-softmmu --audio-drv-list=
	$MAKE	

	cd ..
}

function build_kernel()
{
	if [ -e ${KERENL_DIR}/arch/arm/boot/zImage -a -e ${KERNEL_DIR}/arch/arm/boot/dts/vexpress-v2p-ca9.dtb ]; then
		return
	fi

	cd ${KERNEL_DIR}
	make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm vexpress_defconfig
	$MAKE CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm
	cd ..
}

download
extrace
 
build_qemu
build_kernel

exec_cmd ${QEMU} -M  vexpress-a9 -kernel linux-4.10/arch/arm/boot/zImage -dtb linux-4.10/arch/arm/boot/dts/vexpress-v2p-ca9.dtb -append \"console=ttyAMA0i root=/dev/mmcblk0 rw\" -sd  a9rootfs.ext3