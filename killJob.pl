#!/usr/bin/perl

=head1 Name

killJob.pl  --  kill background Jobs and qsub Jobs 

=head1 Description

Usually you will need to kill or stop your running jobs, whether because they are wrong throwed, or
the CPU/memory is over loaded. To kill a background job(process), we use the "kill process_id" command; 
To kill a qsub job, we use the "qdel job_id" command. Tt is boring to kill so many jobs one by one, or
write shells every time. 

This program will help you get rid of this bother. It search processes or jobs by word patterning, and
then kill them automatically. For the background jobs, the function is not restricted to kill jobs,
but also stop and continue jobs by the "--sig" option.

Note that it is dangerous to kill jobs by word patterning, because this may mis-kill the non-wanted jobs.
So please be alter of the word you selected, it must be special for the job names which you want to be killed.


=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Version: 2.0,  Date: 2007-12-25

=head1 Usage
  
  --pattern <str>   specify a word for patterning
  --signal <str>    kill,stop,or cont, default=kill
  --verbose        output running progress information to screen  
  --help           output help information to screen  

=head1 Exmple



=cut


#################-Main-Function-#################

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;


#get options and parameters
my %opts;
GetOptions(\%opts,"pattern:s","signal:s","verbose!","help!");
die `pod2text $0` if ( $opts{help} || ! $opts{pattern} );

$opts{signal} ||= "kill";

##Constant and global variables
my $program=`basename $0`;	chomp $program;
my $owner=`whoami`; chomp $owner;

##kill background jobs，限制只能识别程序名
my $cmd="ps -u $owner -f | awk '{print \$2,\$8,\$9}' | awk '/$opts{pattern}/ && !/$program/ && !/ awk / {print \"kill -$opts{signal} \",\$1}' | sh";
print $cmd."\n" if(exists $opts{verbose});
system $cmd;

##kill qsub jobs, 限制只能识别程序名
my $cmd="qstat -u $owner | awk '{print \$1,\$3}' | awk '/$opts{pattern}/ && !/$program/ {print \"qdel \",\$1}' | sh";
print $cmd."\n" if(exists $opts{verbose});
system $cmd;


#################-Sub--Routines-#################
