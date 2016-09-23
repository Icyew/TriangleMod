#!/bin/bash
scriptsOnly=false
xmlOnly=false
while getopts ":p:sx" opt; do
	case $opt in
	p)
		path=$OPTARG
		;;
	s)
		scriptsOnly=true
		;;
	x)
		xmlOnly=true
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

#modPath must have a 'content' directory in its first level

echo "Path is $path"

if ! $xmlOnly; then
	for f in $(find $path/* -name "*.ws"); do
		if [[ -f $f ]]; then
			charset=`file -ib "$f" | grep -oP 'charset=\K.+'`;
			if ! [ "$charset" = "utf-8" ]; then
				echo "$charset $f";
			fi
			if [ "$charset" = "iso-8859-1" ]; then
				recode iso-8859-1...utf-8 $f;
			fi
			if [ "$charset" = "utf-16le" ]; then
				recode utf-16le...utf-8 $f;
			fi
			if [ "$charset" = "utf-16be" ]; then
				recode utf-16be...utf-8 $f;
			fi
		fi
	done
fi
if ! $scriptsOnly; then
	for f in $(find $path/* -name "*.xml"); do
		if [[ -f $f ]]; then
			charset=`file -ib "$f" | grep -oP 'charset=\K.+'`;
			if ! [ "$charset" = "utf-16le" ]; then
				echo "$charset $f";
			fi
			if [ "$charset" = "iso-8859-1" ]; then
				recode iso-8859-1...utf-16le $f;
			fi
			if [ "$charset" = "utf-16be" ]; then
				recode utf-16be...utf-16le $f;
			fi
			if [ "$charset" = "utf-8" ]; then
				recode utf-8...utf-16le $f;
			fi
			if [ "$charset" = "us-ascii" ]; then
				recode utf-8...utf-16le $f;
			fi
		fi
	done
fi