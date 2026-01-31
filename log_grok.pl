#!/usr/bin/perl -w
use strict;
use warnings;
####
##pull list of Visitor IPs, count them, then present top NN.
##Theoretically anyway.
##May add top accessed pages as well.
##
####

#User defined variables here:
#1. this is your apache log file to parse (full relative path please)
my $log_filename = "access-ssl.log";
#2. this is how many records you want back (n-1)
my $howmany = 4;
#end of user defined.

#modules and hashes to make life easier
use File::Slurp;
#use Data::Dumper qw(Dumper);
my %ips;
my $count = 0;

#create an array from our log
my @log = read_file ( $log_filename );

#split the file, read the 2nd collumn (IP). and count
foreach my $line (@log){
  my @field = split /\t/, $line;
  if ($ips{$field[1]}){
    $ips{$field[1]}++;
  }
  else{
    $ips{$field[1]}=1;
  }
}

#report on the top NN IPs
foreach my $ip (sort { $ips{$b} <=> $ips{$a} } keys %ips){
  print $ip.": ".$ips{$ip}."\n";
  $count++;
  if ($count gt $howmany) {exit 0;}
}
