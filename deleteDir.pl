#!/usr/bin/perl

## deleteDir.pl -- delete a directory which contains too many subdirectories or 
## files that can't be removed by rm. Here I also advise you do not put too
## subdirectories or files under one directory, it is a bad habit,  will 
## decrease the reading speed, and also cause other problems.

# Author: Fan Wei, fanw@genomics.org.cn

## Date: 2007-1-18

#Include Modules
use strict;
use Getopt::Long; 

#Instructions and advisions of using this program
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE;
Program: delete a directory which contains too many subdirectories or files

Usage: $program  <direcotry> 
	-verbose	output running progress information to screen
	-help		output help information to screen

USAGE

#################-Main-Function-#################

#get options and parameters
my %opts;
GetOptions(\%opts,"verbose!","help!");
die $usage if ( defined $opts{"help"} || @ARGV==0);

my $dir=shift;

die "Sorry, The input direcotry $dir does not exist\n" if(! -d $dir);

##Constant and global variables
my (@path,%report,$total);

@path = split(/\n/,`find $dir`);
@path = reverse @path;
$total = @path;

for (my $i=1; $i<=10; $i++) {
	$report{int $total/10*$i}=$i*10;
}

for (my $i=0; $i<$total; $i++) {
	system "rm -rf $path[$i]";
	if (exists $opts{verbose} && exists $report{$i+1}) {
		printf STDERR ("complete %d\%\n",$report{$i+1});
	}	
}


#################-Sub--Routines-#################
