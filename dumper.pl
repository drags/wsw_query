#!/usr/bin/perl -w

use IO::Socket;
use Data::Dumper;

$host = 'so.nuclearfallout.net';
$port = '44400';

$query_handle = IO::Socket::INET->new(Proto => 'udp', 
		#Blocking => 0,
		PeerAddr => $host, 
		PeerPort => $port)
	or die "socket: $@";

$fourbyte = "ÿÿÿÿ";
$query = $fourbyte . "getstatus EOSeos";

# port to listen on
#$local_port = $query_handle->sockport();

# return socket
#$return_handle = IO::Socket::INET->new(Listen => '1', Proto => 'udp', LocalPort => $local_port) or die "socket: $@";


$query_handle->send($query);

$return_handle = $query_handle->accept();

#while (<$query_handle>) {
do {
	$query_handle->recv($joke,8192);
	print $joke . "\n";
	
} until ($joke ne "\n"); 

