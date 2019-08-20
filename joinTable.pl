#!/usr/bin/perl

## joinTable.pl -- join two tables to form a new one with the specified fileds

## Note that the first table decides the content and order.

## Note that the default seperator of fields is "\t", if the input tables are not,
## then you can set them with -s1, -s2, and -so options.

## the format to write -of option, for example, "1.1,1.3,2.5,2.3", this means the output field 
## order is: column 1 and column 3 of table 1,  column 5 and column 3 of table 2

## the key column is used to correlate the two tables, you can set different key columns by
## option -k1 and -k2

## Author: Fan Wei, fanw@genomics.org.cn

## Date: 2007-1-18

use strict;
use Getopt::Long;

my $program=`basename $0`; chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program: join two tables to form a new one with the specified fileds

Usage: $program  <talbe1> [table2]
    -k1     key column of table1, 1 (defaut)
    -k2     key column of table2, 1 (defaut)
    -of     order of output fields , 1.all,2.all (default) 
    -s1     seperator of table1, default is \\t
    -s2     seperator of table2, default is \\t
    -so     seperator of output, default is \\t
    -help   output help information

USAGE

my %opts;
GetOptions(\%opts, "k1:i","k2:i","of:s","s1:s","s2:s","so:s","help!");
die $usage if ( @ARGV==0 || defined($opts{"help"}));

#****************************************************************#
#--------------------Main-----Function-----Start-----------------#
#****************************************************************#
my $table1_file=shift;
my $table2_file=shift;

$opts{k1} = (defined $opts{k1}) ? $opts{k1} : 1;
$opts{k2} = (defined $opts{k2}) ? $opts{k2} : 1;
$opts{of} = (defined $opts{of}) ? $opts{of} : "1.all,2.all";
$opts{s1} = (defined $opts{s1}) ? $opts{s1} : "\t";
$opts{s2} = (defined $opts{s2}) ? $opts{s2} : "\t";
$opts{so} = (defined $opts{so}) ? $opts{so} : "\t";

my @OUTKEY;
my %TABLE1;
my %TABLE2;
my @ORDER;

foreach  (split (/,/, $opts{of})) {
	if (/([^\.]+)\.([^\.]+)/) {
		push @ORDER, [$1,$2];
	}
}

open IN, $table1_file || die "fail $table1_file";
while (<IN>) {
	s/^\s+//g;
	s/\s+$//g;	
	my @t = split /$opts{s1}/;	
	my $key = $t[$opts{k1}-1];
	push @OUTKEY,$key;
	$TABLE1{$key} = \@t;
}
close IN;

open IN, $table2_file || die "fail $table2_file";
while (<IN>) {
	s/^\s+//g;
	s/\s+$//g;
	my @t = split /$opts{s2}/;
	my $key = $t[$opts{k2}-1];
	if (exists $TABLE1{$key}) {
		$TABLE2{$key} = \@t;
	}
}
close IN;



foreach my $key (@OUTKEY) {
	my $line;
	foreach my $p (@ORDER) {
		if ($p->[0] == 1) {
			if ($p->[1] eq "all") {
				foreach  (@{$TABLE1{$key}}) {
					$line .= $_.$opts{so};
				}
			}else{
				$line .= $TABLE1{$key}[$p->[1]-1].$opts{so};
			}
		}

		if ($p->[0] == 2) {
			if ($p->[1] eq "all") {
				foreach  (@{$TABLE2{$key}}) {
					$line .= (exists $TABLE2{$key}) ? ($_.$opts{so}) : "none".$opts{so};
				}
			}else{
				$line .= (exists $TABLE2{$key}) ? ($TABLE2{$key}[$p->[1]-1].$opts{so}) : "none".$opts{so};
			}
		}
	}
	$line =~ s/$opts{so}$//;
	$line .= "\n";
	print $line;

}