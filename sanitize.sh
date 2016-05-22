#!/bin/bash
reference=false
while getopts "p:r" opt; do
	case $opt in
	p)
		path=$OPTARG
		;;
	r)
		reference=true
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

if $reference; then
	./pruneReference.sh -p "$path"
fi

./recode.sh -p "$path";
# ./notabs.sh -p "$path";