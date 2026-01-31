#!/usr/bin/perl -w

####
#tagfix.pl: fix the CLOUD team's fluff up. Remove a tag from each instance that does not have an ElasticIP
#matt brister <matt.brister@>
#v1.0 8/30/2018 (requires awscli for bash)
####

#use some stuff
use strict;
use warnings;
#use Data::Dumper;
use Array::Utils qw(:all);

#Define a list of instances with EIPs
my @EIP = `aws ec2 describe-addresses --query 'Addresses[*].InstanceId' --output text | tr "\t" "\n"`;
chomp @EIP;

#define a list of instances with the offending tag
my @INSTANCE = `aws ec2 describe-instances --filter \"Name=tag-key,Values='st:stop-at-night-utc'\" --query 'Reservations[*].Instances[*].[InstanceId]' --output text`;
chomp @INSTANCE;

#let's split the difference
my @minus = array_minus( @INSTANCE, @EIP );

#do the thing to the stuff
foreach my $loovar (@minus) {
system "aws ec2 delete-tags --resources ${loovar} --tags Key='st:utc-stop-at-night'";
}
