#!/bin/bash

path=$(pwd)
rm -rf dev_emails.txt

while read gitURL
do
echo "Start cloning : "
git clone $gitURL
if [[ "$?" -ne "0" ]];
then
	break
	echo "Clone failed!"
else
	echo "Cloned sucessfully!"
fi

#split the URL on slash delimiter
tmp=(`echo $gitURL | tr '/' ' '`)

#split the last part of the URL on point delimiter to do away with git extension
arr=(`echo ${tmp[3]} | tr '.' ' '`)

#Retrieve the created app directory's path
appPath="${path}/${arr[0]}"

#Access the app directory
cd $appPath
echo "App path is : $appPath"

#Display and append the log within a log text file
git log > ../${arr[0]}_log.txt
[ "$?" -eq "0" ] && echo "Git log content has been pasted in ${arr[0]}_log.txt successfully!" || echo "Pasting log within ${arr[0]}_log.txt failed!"
sleep 5

#Access the parent directory
cd $path

#Get rid of the app directory
rm -rf $appPath
[ "$?" -eq "0" ] && echo "Cloned app repository deleted successfully!" || echo "Deleting app repository failed!"
sleep 5

#Retrieve emails from log text file
while read line
do

#Select just lines containing authors' informations
if [[ "$line" = "Author: "* ]];
then
if [[ $(grep "$line" dev_emails.txt)]];
then
	echo "Email already exists!"
else
	echo $line >> dev_emails.txt
	echo "Email saved successfully!"
fi
fi
done < ${arr[0]}_log.txt
rm -rf ${arr[0]}_log.txt
done < gitLinks.txt

#Count and display number of scraped emails
totalEmails=(`wc -l dev_emails.txt`)
echo "Total emails scraped : $totalEmails"
sleep 8
