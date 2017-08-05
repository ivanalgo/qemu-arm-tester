#!/bin/bash

RESULT=versions

function kernel_release()
{
	wget https://www.kernel.org/pub/linux/kernel/v4.x/
	egrep -o "linux-[[:digit:]]*.[[:digit:]]*.tar.gz" index.html  | sort | uniq | sed 's/\.tar\.gz//' | sed 's/linux-//'
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

for kernel in $(kernel_release)
do
	test_kernel 2.7.0 ${kernel}
done
