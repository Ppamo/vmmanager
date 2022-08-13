#!/bin/bash
# https://kifarunix.com/how-to-automate-virtual-machine-installation-on-virtualbox/

VMM="/usr/bin/VBoxManage"

usage(){
	printf -- "- Usage:
create: [ARGS]
"
}

list_os(){
	printf "* Listing OS Types:\n"
	$VMM list ostypes
}

create(){
	printf "* Creating new machine:\n"
	NAME=
	OS=
	LISTED_OS=$($VMM list ostypes | grep -Eo "^ID:.*$" | awk '{ print $2 }')
	while [ -n "$1" ]
	do
		case "$1" in
			name)
				NAME="$2"
				shift
				;;
			os)
				OS="$2"
				shift
				;;
			*)
				printf "! Error: arg \'$1\' not found\n"
				usage
				exit 2
		esac
		shift
	done
	printf "%s\n" "$LISTED_OS" | grep "$OS" > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		printf "! ERROR: invalid os type $OS\n"
		exit 5
	fi
	if [ -z "$NAME" -o -z "$OS" ]
	then
		printf "! ERROR: Missing args!\nNAME=%s\nOS=%s\n\n" "$NAME" "$OS"
		exit 4
	fi
	printf "Creating %s machine with name \'%s\':\n" "$OS" "$NAME"
	$VMM createvm --name "$NAME" --ostype "$OS" --register
	if [ $? -ne 0 ]
	then
		printf "! ERROR: Creating command failed!\n"
		exit 3
	fi
}

delete(){
	printf "* Deleting machine \'$1\':\n"
	$VMM unregistervm --delete "$1"
	if [ $? -ne 0 ]
	then
		printf "! ERROR: Delete command failed!\n"
		exit 3
	fi
}


case "$1" in
	create)
		create ${@:2}
		;;
	delete)
		delete ${@:2}
		;;
	lsos)
		list_os
		;;
	*)
		printf "! Error: command not found\n"
		usage
		exit 1
		;;
esac
