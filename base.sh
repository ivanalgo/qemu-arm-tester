#!/bin/bash

function error()
{
	local msg=$1

	echo "=================================================================" 2>&1
	echo "ERROR: $msg"                                                       2>&1
	echo "=================================================================" 2>&1
}

COMMAND_FILE=qemu-${QEMU_v}-kernel-${KERNEL_v}-command-list.log

function init_logging()
{
	echo -n "" > ${COMMAND_FILE}
}

function logging()
{
	local cmd="$@"
	echo "$cmd" >> ${COMMAND_FILE}
}


function exec_cmd()
{
	local cmd=$@

	logging ${cmd}
	eval $cmd

	local ret=$?
	if [ ${ret} -ne 0 ]; then
		error "${cmd}"
		exit ${ret} 
	fi	
}

WGET="wget --no-check-certificate -c"
CPUS=$(cat /proc/cpuinfo  | grep processor | wc -l)
MAKE="make -j${CPUS}"
