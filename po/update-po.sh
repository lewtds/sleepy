#!/bin/bash

#echo "Insert the locale which you want to update:";
#read locale;

#if [ "$locale" == "" ]
#then
#    echo "No locale inserted! Aborting...";
#    exit 1
#fi

for locale in `cat LINGUAS`
do 
	msgmerge -U $locale.po sleepy.pot
done
