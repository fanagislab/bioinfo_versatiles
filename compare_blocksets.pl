#!/usr/bin/perl

=head1 Name

compare_blocksets.pl  --  analyze the redundance inside one block set, or compare the overlap between two block sets

=head1 Description

This is a frequently used program in genome annotation area,
This program can be applied to block TE, ncRNA, and all other function elements, the input could be one or two gff files:
	For one input file, the program will caculate the redundance in the block set.
	For two input files, the program will first caculate the redundance of 
	each block sets, and then calculate the overlap between the two block sets.
	This version does not differentiate strand.

=head1 Version

  Author: Fan Wei, fanweiagis@126.com
  Version: 3.0,  Date: 2016-3-14
  Note:

=head1 Usage
  
  perl compare_blocksets.pl  <file1.gff>  [file2.gff]
  --type1 <str>   block type of the first input file, default=CDS
  --type2 <str>   block type of the second input file, default=CDS
  --verbose   output running progress information to screen  
  --help      output help information to screen  

=head1 Example

  perl ../bin/compare_blocksets.pl  --type1 CDS  chrs.fa.fgenesh.gff
  perl ../bin/compare_blocksets.pl  --type1 CDS --type2 CDS  chrs.fa.fgenesh.gff   chrs.fa.augustus.gff


=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;


##get options from command line into variables and set default values
my ($Type1, $Type2, $Verbose, $Help);
GetOptions(
	"type1:s"=>\$Type1,
	"type2:s"=>\$Type2,
	"verbose"=>\$Verbose,
	"help"=>\$Help
);
$Type1 ||= "CDS";
$Type2 ||= "CDS";
die `pod2text $0` if (@ARGV == 0 || $Help);


my $block_file1 = shift;
my $block_file2 = shift;

my %SCAFF; ##store all the scaffold IDs
my %block1;
my %block2;
my ($All_size1,$Pure_size1,$Redunt_size1); #block set 1
my ($All_size2,$Pure_size2,$Redunt_size2); #block set 2
my ($All_size3,$Pure_size3,$Redunt_size3); #combined the two block sets

##step 1: deal with block_file1
Read_gff($block_file1,\%block1, $Type1);
print STDERR "read $block_file1 done\n" if(defined $Verbose);

 
foreach my $scaff (sort keys %block1) {
	$SCAFF{$scaff} = 1;
	my $scaff_p = $block1{$scaff};
	my $ary = Conjoin_fragment($scaff_p);
	$All_size1 += $ary->[0];
	$Pure_size1 += $ary->[1];
	$Redunt_size1 += $ary->[2];
}

print "\nStatistics for input file ",$block_file1,"\n";
my $Pure_rate1 = sprintf("%.2f\%",$Pure_size1/$All_size1*100);
my $Redunt_rate1 = sprintf("%.2f\%",$Redunt_size1/$All_size1*100);
print "[All_size] $All_size1  =  [Pure_size] $Pure_size1 ($Pure_rate1) +  [Redundant_size] $Redunt_size1 ($Redunt_rate1)\n\n";

exit unless($block_file2);


##step 2: deal with block_file2
Read_gff($block_file2,\%block2, $Type2);
print STDERR "read $block_file2 done\n" if(defined $Verbose);

foreach my $scaff (sort keys %block2) {
	$SCAFF{$scaff} = 1;
	my $scaff_p = $block2{$scaff};
	my $ary = Conjoin_fragment($scaff_p);
	$All_size2 += $ary->[0];
	$Pure_size2 += $ary->[1];
	$Redunt_size2 += $ary->[2];
}

print "\nStatistics for input file ", $block_file2,"\n";
my $Pure_rate2 = sprintf("%.2f\%",$Pure_size2/$All_size2*100);
my $Redunt_rate2 = sprintf("%.2f\%",$Redunt_size2/$All_size2*100);
print "[All_size] $All_size2 =  [Pure_size] $Pure_size2 ($Pure_rate2) +  [Redundant_size] $Redunt_size2 ($Redunt_rate2)\n\n";


##step 3: comparing block_file1 and block_file2
foreach my $scaff (sort keys %SCAFF) {
	my @new;
	push @new, @{$block1{$scaff}} if(exists $block1{$scaff}); 
	push @new, @{$block2{$scaff}} if(exists $block2{$scaff}); 

	my $ary = Conjoin_fragment(\@new);
	$All_size3 += $ary->[0];
	$Pure_size3 += $ary->[1];
	$Redunt_size3 += $ary->[2];

}

print "\nStatistics for the Combined two block sets: \n";
my $Pure_rate3 = sprintf("%.2f\%",$Pure_size3/$All_size3*100);
my $Redunt_rate3 = sprintf("%.2f\%",$Redunt_size3/$All_size3*100);
print "[All_size] $All_size3  =  [Pure_size] $Pure_size3 ($Pure_rate3) +  [Redundant_size] $Redunt_size3 ($Redunt_rate3)\n\n";


print "\nStatistics of overlap on each block set\n";
my $overlap_rate1 = sprintf("%.2f\%",$Redunt_size3 / $Pure_size1 * 100);
my $overlap_rate2 = sprintf("%.2f\%",$Redunt_size3 / $Pure_size2 * 100);
print "block set 1: [Pure_size] $Pure_size1  [Overlap_size] $Redunt_size3  [Overlap_rate] $overlap_rate1\n";
print "block set 2: [Pure_size] $Pure_size2  [Overlap_size] $Redunt_size3  [Overlap_rate] $overlap_rate2\n";




##read gff file, blcoks can be genes, TEs, ncRNAs, and other elements
#usage: Read_gff($file,\%hash);
####################################################
sub Read_gff{
	my $file=shift;
	my $ref=shift;
	my $FilterType = shift;

	open (IN,$file) || die ("fail open $file\n");
	while (<IN>) {
		chomp;
		s/^\s+//;
		my @t = split(/\t/);
		my $tname = $t[0];
		my $type = $t[2];
		my $strand = $t[6];
		my $start = $t[3];
		my $end = $t[4];
		my $qname;
				
		push @{$ref->{$tname}}, [$start,$end] if($type eq $FilterType);
	}
	close(IN);

}




##conjoin the overlapped fragments, and caculate the redundant size
##usage:  my ($all_size,$pure_size,$redunt_size) = conjoin_fragment(\@pos);
##where @pos is a two-dimension array storing the start and end coordinates of all the blocks
sub Conjoin_fragment{
	my $pos_p = shift;      ##point to the two dimension input array
	my $new_p = [];         ##point to the two demension result array
	
	my ($all_size, $pure_size, $redunt_size) = (0,0,0); 
	
	return (0,0,0) unless(@$pos_p);

	foreach my $p (@$pos_p) {
			($p->[0],$p->[1]) = ($p->[0] <= $p->[1]) ? ($p->[0],$p->[1]) : ($p->[1],$p->[0]);
			$all_size += abs($p->[0] - $p->[1]) + 1;
	}
	
	@$pos_p = sort {$a->[0] <=>$b->[0]} @$pos_p;
	push @$new_p, (shift @$pos_p);
	
	foreach my $p (@$pos_p) {
			if ( ($p->[0] - $new_p->[-1][1]) <= 0 ) { # conjoin
					if ($new_p->[-1][1] < $p->[1]) {
							$new_p->[-1][1] = $p->[1]; 
					}
					
			}else{  ## not conjoin
					push @$new_p, $p;
			}
	}
	@$pos_p = @$new_p;

	foreach my $p (@$pos_p) {
			$pure_size += abs($p->[0] - $p->[1]) + 1;
	}
	
	$redunt_size = $all_size - $pure_size;
	return [$all_size,$pure_size,$redunt_size];
}


