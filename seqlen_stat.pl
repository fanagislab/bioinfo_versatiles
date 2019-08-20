#!/usr/bin/perl
=head1 Name

seqlen_stat.pl  -- statistic length of sequence, total, Largest, N10..N90, Minimum.

=head1 Description

Read table format files to get length number, use "--column" option to set the expected column.
The "--cutoff" option is used to filter small sequences, which are often omitted in statistics.

=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Version: 1.0,  Date: 2010-1-7
  Note:

=head1 Usage

  perl seqlen_stat.pl <length_table.txt>
  --column <int>  set column value to get length value, default = 1
  --cutoff <int>  set the minimum cutoff of length value, default = 0
  --verbose   output running progress information to screen  
  --help      output help information to screen  

=head1 Exmple

  perl seqlen_stat.pl --column 4 panda.scafSeq.gapFilled.fa.contig.coor

=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;
use File::Path;  ## function " mkpath" and "rmtree" deal with directory

##get options from command line into variables and set default values
my ($Verbose,$Help, $column,$cutoff);
GetOptions(
	"column:i"=>\$column,
	"cutoff:i"=>\$cutoff,
	"verbose"=>\$Verbose,
	"help"=>\$Help
);
$column ||= 1;
die `pod2text $0` if (@ARGV == 0 || $Help);

my $len_file = shift;

my @len;
my $total_len = 0;
my @NX0;

##read length value from input file
open IN, $len_file || die "fail $len_file";
while (<IN>) {
	next if(/^\#/);
	s/^\s+//;
	s/\s+$//;
	my @t = split(/\s+/,$_); 
	if ($t[$column-1] && $t[$column-1] > 0) {
		next if(defined $cutoff && $t[$column-1] < $cutoff);
		push @len, $t[$column-1];
		$total_len += $t[$column-1];
	}
	
}
close IN;

@len = sort {$b<=>$a} @len;

for (my $i=1; $i<=9; $i++) {
	push @NX0, $total_len / 10 * $i;
}


##calculate total and Larget
my $total_num = @len;
print "Total\t$total_num\t$total_len\n";
print "Maximum\t1\t$len[0]\n";

##calculate N10 to N90
for (my $mark = 1; $mark <= 9; $mark++){
	my $accum_len = 0;
	for (my $i=0; $i<@len; $i++) {
		$accum_len += $len[$i]; 
		if ($accum_len >= $NX0[$mark-1]) {
			print "N$mark"."0\t$i\t$len[$i]\n";
			last;
		}
	}


}


##calculate minimum
print "Minimum\t1\t$len[-1]\n";


####################################################
################### Sub Routines ###################
####################################################

