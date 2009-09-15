#!/usr/bin/perl -w
use IO::Socket;

$host = 'so.nuclearfallout.net';
$port = '44400';

$query_handle = IO::Socket::INET->new(Proto => 'udp', 
		Blocking => 1,
		PeerAddr => $host, 
		PeerPort => $port)
	or die "socket: $@";

$fourbyte = "ÿÿÿÿ";
$fourbyte = chr(255) . chr(255) . chr(255) . chr(255);
$query = $fourbyte . "getstatus";

# port to listen on
#$local_port = $query_handle->sockport();

# return socket
#$return_handle = IO::Socket::INET->new(Listen => '1', Proto => 'udp', LocalPort => $local_port) or die "socket: $@";


$query_handle->send($query);

$query_handle->accept();

#while (<$query_handle>) {
#do {
#	$query_handle->recv($joke,8192);
#	print $joke . "\n";
#	
#} until ($joke ne "\n"); 

#for (my $i = 0; $i < $self->num_clients; $i++) {
while ($_ = <$query_handle>) {
	print;
	open WTF, ">wtf";
	print WTF $_;
	close WTF
}
