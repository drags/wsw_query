#!/usr/bin/perl -w

use IO::Socket;
use Data::Dumper;

$query_handle = IO::Socket::INET->new(Proto => 'udp', PeerAddr => 'so.nuclearfallout.net', PeerPort => '44400') or die "socket: $@";

$fourbyte = "ÿÿÿÿ";
$query = $fourbyte . "getstatus";

# port to listen on
#$local_port = $query_handle->sockport();

# return socket
#$return_handle = IO::Socket::INET->new(Listen => '1', Proto => 'udp', LocalPort => $local_port) or die "socket: $@";


$query_handle->send($query);

$return_handle = $query_handle->accept();

#while ($query_handle->recv($joke,8192)) {
while (<$query_handle>) {
	print $_;
	
}

