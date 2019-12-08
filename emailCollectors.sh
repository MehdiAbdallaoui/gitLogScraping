#!/bin/bash

#PACKAGE REQUIRED TO PLOT GRAPHS: sudo pip3 install termgraph


path=$(pwd)
rm -rf cleaned_emails.txt all_contributors.txt top_10.dat emails_rank.txt

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
sleep 2

#Access the parent directory
cd $path

#Get rid of the app directory
rm -rf $appPath
[ "$?" -eq "0" ] && echo "Cloned app repository deleted successfully!" || echo "Deleting app repository failed!"
sleep 2

#Retrieve emails from log text file and store them all without eliminating the repeated ones
while read line
do

#Store all emails into all_contributors.txt
if [[ "$line" = "Author: "* ]];
then
	tmp=($(echo $line | tr ":" " "))
	echo ${tmp[@]:1} >> all_contributors.txt
fi
done < ${arr[0]}_log.txt

while read line
do

#Select just lines containing authors' informations and eliminate the repeated ones
if [[ "$line" = "Author: "* ]];
then

if [[ $(grep "$line" dev_emails.txt) ]];
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

#Clean emails by removing Authors:
while read line
do

tmp=($(echo $line | tr ":" " "))
echo ${tmp[@]:1} >> cleaned_emails.txt

done < dev_emails.txt
rm -rf dev_emails.txt

#Sort emails alphabetically
sort cleaned_emails.txt > sorted_dev_emails.txt
cp sorted_dev_emails.txt cleaned_emails.txt
rm -rf sorted_dev_emails.txt

#Count and display number of scraped emails
totalEmails=(`wc -l cleaned_emails.txt`)
echo "Total emails scraped : $totalEmails"
sleep 4

#Data analysis
#Most serious contributors
echo "===========================Top 10 contributors==========================="
cat all_contributors.txt | sort | uniq -c | sort -nr | head -10 >> top_10.dat
cat top_10.dat
echo "========================================================================="

#Store best ranked emails' occurences into emails_rank.txt
i=1
while read top
do

occ=($(echo $top | tr " " "\n"))
echo "$i: ${occ[0]}" >> emails_rank.txt
((i=i+1))

done < top_10.dat

#Plot a graph using termgraph
termgraph --title "Contributors Leaderboard" emails_rank.txt --color 'yellow' --format '{:.0f}'
