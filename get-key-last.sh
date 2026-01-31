#!/bin/bash

for user in `aws iam list-users | grep UserName | awk {'print $2'} | sed s/\"//g | sed s/\,//g`; do
  count=`aws iam list-access-keys --user-name $user --output text | awk {'print $2'} | wc -l`
  key=`aws iam list-access-keys --user-name $user --output text | awk {'print $2'}`
    if [ "$count" -eq "2" ]; then
    echo $user,"multiple"
      elif [ "$count" -eq "0" ]; then
      echo $user,"none"
        elif [ "$count" -eq "1" ]; then
          last=`aws iam get-access-key-last-used --access-key-id $key --output text | awk {'print $2'}`
           echo $user,$last
   fi
done
