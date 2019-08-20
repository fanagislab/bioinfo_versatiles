#!/usr/bin/perl

## download_url.pl -- download data from website by url information
##		note that this program work well in windows system, but unix not.

# Author: Fan Wei, fanw@genomics.org.cn

## Date: 2007-1-18


use strict;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
 
use IO::Socket::INET;
use Getopt::Std;

## Only work well under windows system
#####################################################


my $url = qq(http://www.baidu.com/);
print STDERR $url."\n";
print Download($url);


#####################################################
sub Download {
	 my $url = shift;
	 $| = 1;
	 my $CRLF  = "\015\012";

	 my $S = IO::Socket::INET->new(  #S stands for socket
	  PeerAddr => "192.168.4.3",
	  PeerPort => "80",
	  Proto => "tcp",
	  Type => SOCK_STREAM	 
	 ) || die("Cannot open the socket\n");
 

	 my $request = join($CRLF => "GET $url HTTP/1.0"	, "" => "" );
   
	 print $S $request;
	 
	 my $protocol=<$S>;
	 my $proxy=<$S>;
	 my $type=<$S>;
	 my $space=<$S>;
	 my $content;
	 while (<$S>) {  
	    $content .= $_;
	 }
	 close($S);

	 return $content;
}
