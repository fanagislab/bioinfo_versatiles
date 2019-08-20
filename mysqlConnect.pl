#!/usr/bin/perl

## mysqlConnect.pl -- connect to mysql database using perl, here is only an example.
##		In order to use DBI module, DBD module must be installed, and these two modules
##		must be installed by "install" command because of containing C codes, 
##		Currently, only sun162 and Dawn4000 support DBI and DBD.

# Author: Fan Wei, fanw@genomics.org.cn

## Date: 2007-1-18

use strict;
use DBI;

my $h="192.168.4.35";
my $d="mywork";
my $u="fanw";
my $p="0000";

my @data;

my $dbh=DBI->connect("dbi:mysql:dbname=$d",$u,$p) or die "wrong:".DBI->errstr;
my $sth=$dbh->prepare("select * from test");
$sth->execute() or die "can not:" . $sth->errstr;
while (@data = $sth->fetchrow_array()) {
	print "id:$data[0]\tname:$data[1]\n";
}
$dbh->disconnect;