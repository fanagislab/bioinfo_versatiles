#!/usr/bin/perl

=head1 Name

fqfa.pl  -- convert between fa and fq format

=head1 Description

convert fa to fq, or fq to fa format, output to stdout
Note that both fa and fq are in the one-line per sequence format

=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Version: 1.0,  Date: 2006-12-6
  Note:

=head1 Usage
  
  fqfa.pl [option] input_file 
  --convert   two options fq2fa and fa2fq, default=fq2fa
  --verbose   output running progress information to screen  
  --help      output help information to screen  

=head1 Exmple



=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;
use File::Path;  ## function " mkpath" and "rmtree" deal with directory

##get options from command line into variables and set default values
my ($Convert, $Verbose,$Help);
GetOptions(
	"convert:s"=>\$Convert,
	"verbose"=>\$Verbose,
	"help"=>\$Help
);
$Convert ||= "fq2fa";
die `pod2text $0` if (@ARGV == 0 || $Help);

my $file = shift;

open IN,$file || die "can not open $file:$!";


if ($Convert =~ /fq2fa/i) {
	while (<IN>) {
		if (/^@/) {
			my $read_head = $_;
			$read_head =~ s/^@/>/;
			my $read_seq = <IN>;
			<IN>;
			<IN>;
			print $read_head.$read_seq;
		}
	}
}


if ($Convert =~ /fa2fq/i) {
	while (<IN>) {
		if (/^>/) {
			my $read_head = $_;
			$read_head =~ s/^>/@/;
			my $read_seq = <IN>;
			my $read_len = length($read_seq) - 1;
			my $read_qual = 'B' x $read_len;
			print $read_head.$read_seq."+\n".$read_qual."\n";
		}
	}
}

close IN;

####################################################
################### Sub Routines ###################
####################################################
