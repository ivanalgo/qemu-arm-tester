#!/bin/bash

function error()
{
	local msg=$1

	echo "=================================================================" 2>&1
	echo "ERROR: $msg"                                                       2>&1
	echo "=================================================================" 2>&1
}

function WGET()
{
	local url=$1

	if ! wget -c  --no-check-certificate $url; then
		error "Download $url error, exiting"
		exit 1
	fi
}
