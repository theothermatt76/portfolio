#!/bin/bash
######
#monitoreni.sh - Monitor ENI with Public IPs
##
#This script is meant to be ran on a cron schedule, every 5 minutes. It polls a
#list of the current Public IPs in use in our environment, and compares then to
#the previous run's results. If there is a difference, it sends the IP and ENI
#name to the individual in charge of monitoring and fixing this.
##
#Version 1.0, 8/23/2019 - Matt Brister (matt.brister@)
#Version 2.0, 9/5/2019 - MB (Adds support for SSM and SNS instead of persistent files and mailx)
######

handler () {
  set -e
#get the list of IPs in our account
region=$(aws ec2 describe-regions | jq -r '.Regions[].RegionName')
for each in `echo $region`; do
  aws ec2 describe-network-interfaces --region $each | jq ".NetworkInterfaces[].Association.PublicIp" | sed s/\"//g | grep -v null | sort -n | uniq >> /tmp/eninew;
done
#and import the list from the last run
aws ssm get-parameter --region us-east-1 --name eni_monitor | grep Value | awk {'print $2'} | sed s/\"//g | sed s/,//g | sed s/\n/\/g | sed 's/\\/\n/g' > /tmp/enimonitor
#find a diff between the arrays...
tmparray=$(diff /tmp/eninew /tmp/enimonitor | grep "<" | awk {'print $2'})
#if there is a diff, get the eni info and write it to file
if [ -z "$tmparray" ]; then
  echo "foo" > /dev/null
else
	  echo "Please check these ENIs and delete as necessary:" > /tmp/enibody
    echo "Availability zone   Network Adaptor" >> /tmp/enibody
    echo "___________________________________" >> /tmp/enibody
    for i in `echo $tmparray`; do aws ec2 describe-network-interfaces --filters Name=association.public-ip,Values=$i | grep "NetworkInterfaceId\|AvailabilityZone" | awk {'print $2'} | sed s/\"//g | sed s/,//g | tr '\n' ' ' >> /tmp/enibody; done
fi
#publish message
if [ -e /tmp/enibody ];
  then
    aws sns publish --region us-east-1 --topic-arn "arn:aws:sns:yadaYada" --message file:///tmp/enibody --subject "New PUBLIC IP in DEV!" > /dev/null
fi
#update enimonitor parameter
aws ssm put-parameter --region us-east-1 --name eni_monitor --type StringList --value file:///tmp/eninew --overwrite > /dev/null
}
