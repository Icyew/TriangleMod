#!/bin/bash
files=$(find ./Witcher3/content/scripts/ -type f -name "*.ws")
for file in $files; do
	perl -pi -e 's/(\r(?=[^\n])|(\r(?=\z)))/\r\n/g' $file;
done
find ./Witcher3/content/scripts/ -type f -name "*.bak" -delete;