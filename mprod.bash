#!/bin/bash

function mprod()
{
	if [ $# -lt 1 ]
	then
		echo "Branch name missing"
		exit 1
	fi

	local arg=$1

	if [[ $1 != origin/* ]]
	then
		arg=origin/$1
	fi

	git merge --no-ff -sresolve $arg
}

mprod $@
