#!/bin/bash
scriptsOnly=false
xmlOnly=false
while getopts "m:g:sx" opt; do
	case $opt in
	m)
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

tmpPath="./temp"

if [ -z "$modPath" ]; then
	echo "Mod path -m must be defined";
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

currentChanges=$(git status --porcelain | cut -c4-)
oldChanges=$(git diff --name-only vanilla..HEAD)
prefix="Witcher3"
mkdir -p "$tmpPath"
for file in $currentChanges $oldChanges; do
	if [[ $file =~ ^$prefix ]]; then
		filePath="$modPath/$file"
		if ([[ $file =~ .*".xml"$ ]] && ! $scriptsOnly) || ([[ $file =~ .*".ws"$ ]] && ! $xmlOnly); then
			echo "$filePath";
			cp -R --parents "$filePath" "$tmpPath";
		fi
	fi
done

# if $scriptsOnly ; then
# 	cp -R "$scriptPath" "$tmpPath/content"
# else
# 	cp -R "$contentPath" "$tmpPath"
# fi
cp -R "$binPath" "$gamePath"

# eval "$batPath"

read -p "After packing is complete, press enter to delete temp files!"

rm -r "./temp"
