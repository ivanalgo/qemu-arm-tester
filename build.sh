#!/bin/bash

RESULT=versions

function kernel_release()
{
	wget -c https://www.kernel.org/pub/linux/kernel/v4.x/ --default-page kernel_release
	egrep -o "linux-[[:digit:]]*.[[:digit:]]*.tar.gz" kernel_release  | sort | uniq | sed 's/\.tar\.gz//' | sed 's/linux-//'
}

function qemu_release()
{
	wget -c https://download.qemu.org/	 --default-page qemu_release
	egrep -o "qemu-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+.tar.xz" qemu_release |sort | uniq | sed -e 's/qemu-//' -e 's/\.tar.xz//'	
}

function test_kernel()
{
	qver=$1
	kver=$2

	if grep -q "qemu:${qver} kernel:${kver}" $RESULT; then
		# this version pair have been tested, skip it
		return
	fi

	${dir}/build_one.sh ${qver} ${kver}
	if [ $? -eq 0 ]; then
		echo "qemu:${qver} kernel:${kver} success" >> $RESULT
	else
		echo "qemu:${qver} kernel:${kver} failure" >> $RESULT
	fi
}

dir=$(dirname $0)
dir=$(pwd)/${dir}

qemu_list=$(qemu_release)
kernel_list=$(kernel_release)

for qemu in ${qemu_list}
do
	# start qemu version begin with 2.x.x
	if echo $qemu | egrep  -q "[0,1]\.[[:digit:]]+\.[[:digit:]]+"; then
		continue
	fi

	for kernel in ${kernel_list}
	do
		test_kernel ${qemu} ${kernel}
	done
done
