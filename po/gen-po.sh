#!/bin/bash

echo "Insert your locale:";
read locale;

if [ "$locale" == "" ]
then
    echo "No locale inserted! Aborting...";
    exit 1
fi

#mkdir -p $locale/LC_MESSAGES
msginit --locale=$locale --input=sleepy.pot --output=$locale.po
echo $locale >> LINGUAS
