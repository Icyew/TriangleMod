#!/bin/bash
scriptsOnly=false
xmlOnly=false
debug=false
while getopts "p:g:sxd" opt; do
	case $opt in
	p)
		modPath=$OPTARG
		;;
	g)
		gamePath=$OPTARG
		;;
	s)
		scriptsOnly=true
		;;
	x)
		xmlOnly=true
		;;
	d)
		debug=true
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

tmpPath="$modPath/temp"

if [ -z "$modPath" ]; then
	echo "Mod path -p must be defined";
	exit 1;
fi

if [ -z "$gamePath" ]; then
	echo "Game path -g must be defined";
	exit 1;
fi

#modPath must have a 'content' directory in its first level

echo "Working directory is $modPath (should have Witcher3 as immediate child)"
echo "Scripts only? $scriptsOnly"
echo "Game folder is $gamePath"

#if temp already exists, delete it
if test -e $tmpPath ; then
	rm -r $tmpPath
fi

contentPath="$modPath/Witcher3/content"
scriptPath="$contentPath/scripts"
batPath="$modPath/pack.bat"
binPath="$modPath/bin"
studioPath="$modPath/../ScriptStudio"

if test -e "$studioPath/scripts/local/"; then
	rm -r "$studioPath/scripts/local/";
	mkdir "$studioPath/scripts/local/";
fi
if test -e "$studioPath/scripts/source/"; then
	rm -r "$studioPath/scripts/source/";
	mkdir "$studioPath/scripts/source/";
fi

currentChanges=$(git diff --name-status vanilla)

prefix="Witcher3"
mkdir -p "$tmpPath"
# chmod 774 "$tmpPath"
IFS=$'\n'
for fileWithStatus in $currentChanges; do
	status=$(echo "$fileWithStatus" | grep -oP "^.*?\S" | grep -o "\S")
	file=$(echo "$fileWithStatus" | grep -o "$prefix.*$")
	if [[ $file =~ ^$prefix ]] && ([[ $status == "M" || $status == "A" ]]); then
		filePath="$modPath/$file"
		if [[ $file =~ .*".xml"$ ]] && ! $scriptsOnly; then
			echo "$filePath";
			cp -Rp --parents "$filePath" "$tmpPath";
		fi
		if [[ $file =~ .*".ws"$ ]] && ! $xmlOnly; then
			echo "$filePath";
			if $debug; then
				truncatedPath=${filePath#$scriptPath}
				folder="source"
				if [[ $status == "A" ]]; then
					folder="local"
				fi
				localPath="$studioPath/scripts/$folder/$truncatedPath"
				pathOnly=${localPath%/*}
				mkdir -p "$pathOnly";
				cp -Rp "$filePath" "$localPath";
			else
				cp -Rp --parents "$filePath" "$tmpPath";
			fi
		fi
	fi
done

# if $scriptsOnly ; then
# 	cp -R "$scriptPath" "$tmpPath/content"
# else
# 	cp -R "$contentPath" "$tmpPath"
# fi
# chmod -R 774 "$binPath"
cp -Rp "$binPath" "$gamePath"

eval "$batPath"

read -p "After packing is complete, press enter to delete temp files!"

rm -r "./temp"
