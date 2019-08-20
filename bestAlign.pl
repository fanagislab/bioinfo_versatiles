#!/usr/bin/perl

=head1 Name

bestAlign.pl  --  choose the best hit for aligning

=head1 Description

This program can choose the best hit from aligning result,
accept psl m6 m8 hmmer and solar format now. 
For psl, according to highest base matching rate
For m6 and m8, according to lowest e-value
For solar, according to highest aligning rate

=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Version: 1.0,  Date: 2007-2-7

=head1 Usage

  --fileformat   set input file format, psl, m6, m8, hmmer, paf, solar are supported
  --cutoff       set a cut off to filter low quality alignments
  --verbose      output verbose information to screen  
  --help         output help information to screen  

=head1 Exmple

perl bestAlign.pl example.psl -cutoff 0.5
perl bestAlign.pl example.m8 -cutoff 1e-5
perl bestAlign.pl example.solar -cutoff 0.5

=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;

my ($Fileformat,$Cutoff,$Verbose,$Help);
GetOptions(
	"fileformat:s"=>\$Fileformat,
	"cutoff:s"=>\$Cutoff,
	"verbose"=>\$Verbose,
	"help"=>\$Help
);
die `pod2text $0` if (@ARGV == 0 || $Help);

my %Data;

read_psl() if($Fileformat eq 'psl' || $ARGV[0] =~ /\.psl$/);
read_m8() if($Fileformat eq 'm8' || $ARGV[0] =~ /\.m8$/);
read_m6() if($Fileformat eq 'm6' || $ARGV[0] =~ /\.m6$/);
read_hmmer() if($Fileformat eq 'hmmer' || $ARGV[0] =~ /\.hmmer$/);
read_solar() if($Fileformat eq 'solar' || $ARGV[0] =~ /\.solar$/);
read_paf() if($Fileformat eq 'paf' || $ARGV[0] =~ /\.paf$/);


foreach my $qname (sort keys %Data) {
	print $Data{$qname}{line},"\n";
}

####################################################
################### Sub Routines ###################
####################################################


sub read_psl{
	while (<>) {
		chomp;
		my @temp = split /\t/;
		my $qname = $temp[9];
		my $value = $temp[0] / $temp[10]; ##精确匹配碱基率
		next if(defined $Cutoff && $value < $Cutoff);
		if (! exists $Data{$qname} || $Data{$qname}{value} < $value) {
			$Data{$qname}{value} = $value;
			$Data{$qname}{line} = $_;
		}
	}
}

##blast+ tabular format
sub read_m6{
	while (<>) {
		chomp;
		my @temp = split /\t/;
		my $qname = $temp[0];
		my $value = $temp[13]; ##E-value
		next if(defined $Cutoff && $value > $Cutoff);
		if (! exists $Data{$qname} || $Data{$qname}{value} > $value) {
			$Data{$qname}{value} = $value;
			$Data{$qname}{line} = $_;
		}
	}
}



##blast tabular format
sub read_m8{
	while (<>) {
		chomp;
		my @temp = split /\t/;
		my $qname = $temp[0];
		my $value = $temp[10]; ##E-value
		next if(defined $Cutoff && $value > $Cutoff);
		if (! exists $Data{$qname} || $Data{$qname}{value} > $value) {
			$Data{$qname}{value} = $value;
			$Data{$qname}{line} = $_;
		}
	}
}


##hmmscan --domtblout format
sub read_hmmer{
	while (<>) {
		next if(/^\#/);
		chomp;
		my @temp = split /\s+/;
		my $qname = $temp[3];
		my $value = $temp[6]; ##E-value
		next if(defined $Cutoff && $value > $Cutoff);
		if (! exists $Data{$qname} || $Data{$qname}{value} > $value) {
			$Data{$qname}{value} = $value;
			$Data{$qname}{line} = $_;
		}
	}
}


sub read_solar{
	while (<>) {
		chomp;
		my @temp = split /\t/;
		my $qname = $temp[0];
		my $qlen = $temp[1];
		my $align_len;
		while ($temp[11] =~ /(\d+),(\d+);/g) {
			$align_len += $2 - $1 + 1;
		}
		my $value = $align_len / $qlen; ##align rate
		next if(defined $Cutoff && $value < $Cutoff);
		if (! exists $Data{$qname} || $Data{$qname}{value} < $value) {
			$Data{$qname}{value} = $value;
			$Data{$qname}{line} = $_;
		}
	}
}



##read the paf format by minimap
sub read_paf{
	while (<>) {
		chomp;
		my @temp = split /\t/;
		my $qname = $temp[0];
		my $value = ($temp[3] - $temp[2])/$temp[1]; ##overlap length / read length, i.e.  overlap ratio
		next if(defined $Cutoff && $value > $Cutoff);
		if (! exists $Data{$qname} || $Data{$qname}{value} < $value) {
			$Data{$qname}{value} = $value;
			$Data{$qname}{line} = $_;
		}
	}
}

