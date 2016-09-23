#!/bin/bash
while getopts "p:" opt; do
	case $opt in
	p)
		path=$OPTARG
		;;
	\?)
  		echo "Invalid option: -$OPTARG" >&2
 		exit 1
  		;;
	:)
  		echo "Option -$OPTARG requires an argument." >&2
  		exit 1
  		;;
	esac
done
if [ -z "$path" ]; then
	echo "Path -p must be defined";
	exit 1;
fi
tail -f -n +1 "$path" | grep "TMod"

