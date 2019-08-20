#!/usr/bin/perl

=head1 Name

find_overlap.pl  --  find overlap relations between two block sets on chromosome

=head1 Description

This program is designed to find overlap relations of blocks, 
The algorithm is that: (1) sort the two block sets based on start positions, seperately;
(2) walk along the chromosome, and find out overlap between the two block sets.
(3) report who and who overlapped, as well as their own size and the overlapped size.

The input file is in table format, tab delimitated, with each columun means:
 chr_id, block_id, start_position, end_position

The table format of output file, with each column means: 
  Column 1: the query ID; 
  Column 2: the query size; 
  Column 3: chromosome ID; 
  Column 4: number of target blocks overlapped with query block; 
  Column 5+: each columun for one overlapped target block, with target block id, target block size, and the overlapped size 


=head1 Version

  Author: Fan Wei, fanweiagis@126.com
  Version: 2.0,  Date: 2016-03-17

=head1 Usage
  
  perl find_overlap.pl <query_blocks.tab> [target_blocks.tab]
  --verbose   output verbose information to screen  
  --help      output help information to screen  

=head1 Exmple

  Find overlap relationships within one input block set:
  perl find_overlap.pl  gene_predictions.tab >  gene_predictions.tab.overlap.vs.itself
  
  Find overlap relationships between two input block sets:
  perl find_overlap.pl  gene_predictions1.tab  gene_predictions2.tab  > gene_predictions1.tab.overlap.vs.gene_predictions2


=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;

my ($Verbose,$Help);
GetOptions(
	"verbose"=>\$Verbose,
	"help"=>\$Help
);
die `pod2text $0` if (@ARGV < 1 || $Help);

my $ref_file=shift;
my $pre_file=shift || $ref_file;

my ( %Ref, %Pre );

read_table($ref_file,\%Ref);


print STDERR "read input1_file done\n" if($Verbose);


read_table($pre_file,\%Pre);

print STDERR "read input2_file done\n" if($Verbose);


find_overlap(\%Ref,\%Pre);

print STDERR "find overlap done\n" if($Verbose);


####################################################
################### Sub Routines ###################
####################################################



sub find_overlap{
	my $Ref_hp=shift;
	my $Pre_hp=shift;
	
	foreach  my $chr (sort keys %$Ref_hp) {
		
		my $output;
		my @ref_chr = (exists $Ref_hp->{$chr})  ? (sort {$a->[0] <=> $b->[0]} @{$Ref_hp->{$chr}}) : ();
		my @pre_chr = (exists $Pre_hp->{$chr})  ? (sort {$a->[0] <=> $b->[0]} @{$Pre_hp->{$chr}}) : ();
		
		print STDERR "find overlap on $chr\n" if($Verbose);
		
		my $pre_pos = 0;
		for (my $i=0; $i<@ref_chr; $i++) {
			my $ref_gene = $ref_chr[$i][2];
			my $ref_size = $ref_chr[$i][1] - $ref_chr[$i][0] + 1;
			my @overlap;
			
			for (my $j=$pre_pos; $j<@pre_chr; $j++) {
				if ($pre_chr[$j][1] < $ref_chr[$i][0]) {
					$pre_pos++;
					next;
				}
				if ($pre_chr[$j][0] > $ref_chr[$i][1]) {
					last;
				}
				
				my $pre_size = $pre_chr[$j][1] - $pre_chr[$j][0] + 1;
				my $overlap_size = overlap_size($pre_chr[$j],$ref_chr[$i]);
				
				push @overlap,"$pre_chr[$j][2],$pre_size,$overlap_size";
			}
			
			$output .= $ref_gene."\t".$ref_size."\t".$chr."\t".scalar(@overlap)."\t".join("\t",@overlap)."\n";
		}

		print $output;
	}

}


sub overlap_size {
	my $block1_p = shift;
	my $block2_p = shift;
	
	my $combine_start = ($block1_p->[0] < $block2_p->[0]) ?  $block1_p->[0] : $block2_p->[0];
	my $combine_end   = ($block1_p->[1] > $block2_p->[1]) ?  $block1_p->[1] : $block2_p->[1];
	
	my $overlap_size = ($block1_p->[1]-$block1_p->[0]+1) + ($block2_p->[1]-$block2_p->[0]+1) - ($combine_end-$combine_start+1);

	return $overlap_size;
}


sub read_table{
	my $file=shift;
	my $ref=shift;
	open(REF,$file)||die("fail to open $file\n");
	while (<REF>) {
		chomp;
		my @temp=split(/\t/,$_);
		my $chr=$temp[0];
		my $gene=$temp[1];
		my $start=$temp[2];
		my $end=$temp[3];
		
		next if($start !~ /\d/);
		push @{$ref->{$chr}},[$start,$end,$gene];
	}
	close(REF);
}




