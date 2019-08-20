#!/usr/bin/perl

## synDir.pl -- synchronize the source dircetoy and the target directory,
##		can be used in both unix system, and windows system. This can also be done
##		by copying the whole source directory to the target postion, but it will
##		cost much more time than only copying the different files. This program
##		is designed for large/huge and daily/weekly data backup.
##		note that directory could not be root disk, for example E:\

## Examples: 
##	perl synDir.pl E:\3.interest  I:\3.interest
##	perl synDir.pl /disk2/fanw/rice  /disk10/fanw/rice_bak

## Author: Fan Wei, fanw@genomics.org.cn
## Version: 1.0
## Date: 2007-1-18

use strict;
use File::Copy;  ## functions "copy" and "move" deal with file
use File::Path;  ## function " mkpath" and "rmtree" deal with directory

die "Synchronize targetdir with sourcedir\nUsage: $0 <source_dir> <target_dir>\n" if(@ARGV != 2);

my $sourcedir = shift;
my $targetdir = shift;

$sourcedir=~tr/\\/\//;
$targetdir=~tr/\\/\//;
$sourcedir=~s/\/$//;
$targetdir=~s/\/$//;

my %sourcefiles;
my %targetfiles;
my %sourcesubdirs;
my %targetsubdirs;

mkdir($targetdir) if(! -d $targetdir);

read_dir($sourcedir,\%sourcefiles,\%sourcesubdirs);
read_dir($targetdir,\%targetfiles,\%targetsubdirs);

##step 1: remove subdirs in target, but not in source
foreach my $targetsubdir (keys %targetsubdirs) {
	my $sourcesubdir = $targetsubdir;
	$sourcesubdir =~ s/^$targetdir/$sourcedir/;
	if (! exists $sourcesubdirs{$sourcesubdir}) {
		rmtree($targetsubdir);
	}
}

##step 2: remove files in target, but not in source
foreach my $targetfile (keys %targetfiles) {
	my $sourcefile = $targetfile;
	$sourcefile =~ s/^$targetdir/$sourcedir/;
	if (! exists $sourcefiles{$sourcefile}) {
		unlink($targetfile);
	}
}

##step 3: creat subdirs in source but not in target
foreach my $sourcesubdir (keys %sourcesubdirs) {
	my $targetsubdir = $sourcesubdir;
	$targetsubdir =~ s/^$sourcedir/$targetdir/;
	if (! exists $targetsubdirs{$targetsubdir}) {
		mkpath($targetsubdir);
	}
}

##step 4: creat files in source but not in target, or not in the same size and time
foreach my $sourcefile (keys %sourcefiles) {
	my $targetfile = $sourcefile;
	$targetfile =~ s/^$sourcedir/$targetdir/;
	if (! exists $targetfiles{$targetfile}) {
		copy($sourcefile,$targetfile);
	}else{
		my @sary = stat($sourcefile);
		my @tary = stat($targetfile);
		if ($sary[7] != $tary[7] || $sary[9] != $tary[9]) {
			copy($sourcefile,$targetfile);
		}
	}
}


## read all the files and subdirectories recursively 
sub read_dir{
	my $dir = shift;
	my $files_p = shift;
	my $subdirs_p = shift;
	
	opendir IN, $dir || die "fail open $dir\n";
	my @subdir = readdir(IN); ## get all the contents directly under $dir
	shift @subdir; shift @subdir; ## remove . and ..
	close IN;
	
	foreach  my $sub (@subdir) {
		
		if (-f $dir."/".$sub) {
			$files_p->{$dir."/".$sub} = 1;
		}
		if (-d $dir."/".$sub) {
			$subdirs_p->{$dir."/".$sub} = 1;
			read_dir($dir."/".$sub,$files_p,$subdirs_p); ## recursion
		}
	}

}