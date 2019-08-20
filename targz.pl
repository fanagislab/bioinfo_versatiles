#!/usr/bin/perl

## targz.pl -- combine the function of tar and gzip, convert directory
##		to directory.tar.gz, and the reverse, automatically.

## Author: Fan Wei, fanw@genomics.org.cn

## Date: 2007-1-18

use strict;
use Getopt::Long; 

my $program_name=$1 if($0=~/([^\/]+)$/);
my $usage=<<USAGE;
Program: combine the function of tar and gzip

Usage: $program_name  <directory | dirctory.tar.gz> ... 
	-help	output help information to screen

USAGE

#################-Main-Function-#################
my %opts;
GetOptions(\%opts,"help!");
die $usage if ( @ARGV < 1 || exists $opts{"help"} );

my $target = shift;
$target =~ s/\/$//;

die "target not exist\n" if(! -e $target);

if($target=~/\.tar\.gz$/){
	`gzip -d $target`;
	$target =~ s/\.gz$//;
	`tar xf $target`;
	`rm $target`;
}else{
	`tar cf $target.tar $target`;
	`gzip $target.tar`;
	`rm -r $target`;
}



#################-Sub--Routines-#################




__END__