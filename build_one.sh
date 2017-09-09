#!/bin/bash


################################################################################
#                                                                              #
# build_one.sh  <qemu-version> <kernel-version>                                #
#                                                                              #
################################################################################


EXEC_PATH=$(dirname $0)
QEMU_v=$1
KERNEL_v=$2

. base.sh

QEMU_DIR=qemu-${QEMU_v}
QEMU_COMPRESS_FILE=${QEMU_DIR}.tar.bz2
QEMU_URL=https://download.qemu.org/${QEMU_COMPRESS_FILE}
KERNEL_DIR=linux-${KERNEL_v}
KERNEL_COMPRESS_FILE=${KERNEL_DIR}.tar.gz
KERNEL_URL=https://www.kernel.org/pub/linux/kernel/v4.x/${KERNEL_COMPRESS_FILE}

echo "qemu = ${QEMU_v} kernel = ${KERNEL_v}"
init_logging

QEMU="qemu-${QEMU_v}/arm-softmmu/qemu-system-arm -nographic -no-reboot"



function download()
{
	exec_cmd ${WGET} ${QEMU_URL}
	exec_cmd ${WGET} ${KERNEL_URL}
}


function extrace()
{
	#if [ ! -e ${QEMU_DIR} ]; then
		exec_cmd tar jxf ${QEMU_COMPRESS_FILE}
	#fi

	#if [ ! -e ${KERNEL_DIR} ]; then
		exec_cmd tar zxf ${KERNEL_COMPRESS_FILE}
	#fi
}

function build_qemu()
{
	#if [ -e ${QEMU_DIR}/arm-softmmu/qemu-system-arm ]; then
	#	return
	#fi

	exec_cmd cd ${QEMU_DIR}
	exec_cmd ./configure --target-list=arm-softmmu --audio-drv-list=
	exec_cmd ${MAKE}

	exec_cmd cd ..
}

function build_kernel()
{
	#if [ -e ${KERNEL_DIR}/arch/arm/boot/zImage -a -e ${KERNEL_DIR}/arch/arm/boot/dts/vexpress-v2p-ca9.dtb ]; then
	#	return
	#fi

	exec_cmd cd ${KERNEL_DIR}
	exec_cmd ${MAKE} CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm vexpress_defconfig
	exec_cmd ${MAKE} CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm
	exec_cmd cd ..
}

download
extrace
 
build_kernel
build_qemu

timeout --foreground 60s ${EXEC_PATH}/start-vexpress.sh ${QEMU_DIR}/arm-softmmu/qemu-system-arm ${KERNEL_DIR} a9rootfs.ext3
