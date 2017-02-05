#!/bin/bash
while getopts ":p:" opt; do
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
	echo "Path -p not specified";
	exit 1;
fi

find "$path" -name '*.ws' ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;;
find "$path" -name '*.xml' ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;;