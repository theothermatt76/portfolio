#!/bin/bash
######
#get-role-last-used.sh
#Matt Brister <matt.brister@>
#V1.0 1/16/2019 - initial release
###
#Gets a list of all roles in an aws account (anywhere it has rights)
#and determines when the role was last used
####

ARN=`aws iam list-roles --no-paginate | grep "arn:" | awk '{print $2}' | sed 's/\"//g' | sed 's/,//g'`
  for i in $ARN; do
  JOBID=`aws iam generate-service-last-accessed-details --arn $i --output text`
    for e in $JOBID; do
    aws iam get-service-last-accessed-details --job-id $e | egrep "LastAccessedEntity|LastAccessed" | awk '{print $2}' | sed 's/,//g' | xargs
    done
  done
