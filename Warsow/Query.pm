#!/usr/bin/perl -w
use IO::Socket;

package Query; 
use strict;

sub new {
	my $self = {};
	$self->{MOD} = undef;
	$self->{SCORES} = undef;
	$self->{MATCH_TIME} = undef;
	$self->{NEED_PASS} = undef;
	$self->{MAP_NAME} = undef;
	$self->{HOST_NAME} = undef;
	$self->{MAX_CLIENTS} = undef;
	$self->{GAME_TYPE} = undef;
	$self->{NUM_CLIENTS} = undef;
	$self->{CLIENTS} = [];
	bless ($self);
	return $self;
}


sub mod {
	my $self = shift;
	if (@_) { $self->{MOD} = shift }
	return $self->{MOD};
}

sub scores {
	my $self = shift;
	if (@_) { $self->{SCORES} = shift }
	return $self->{SCORES};
}

sub match_time {
	my $self = shift;
	if (@_) { $self->{MATCH_TIME} = shift }
	return $self->{MATCH_TIME};
}

sub need_pass {
	my $self = shift;
	if (@_) { $self->{NEED_PASS} = shift }
	return $self->{NEED_PASS};
}

sub map_name {
	my $self = shift;
	if (@_) { $self->{MAP_NAME} = shift }
	return $self->{MAP_NAME};
}

sub host_name {
	my $self = shift;
	if (@_) { $self->{HOST_NAME} = shift }
	return $self->{HOST_NAME};
}

sub max_clients {
	my $self = shift;
	if (@_) { $self->{MAX_CLIENTS} = shift }
	return $self->{MAX_CLIENTS};
}

sub game_type {
	my $self = shift;
	if (@_) { $self->{GAME_TYPE} = shift }
	return $self->{GAME_TYPE};
}

sub num_clients {
	my $self = shift;
	if (@_) { $self->{NUM_CLIENTS} = shift }
	return $self->{NUM_CLIENTS};
}

sub clients {
	my $self = shift;
	if (@_) { push @{ $self->{CLIENTS} }, @_ };
	return @{ $self->{CLIENTS} };
}

sub GetData {
	my $self = shift;
	my ($host, $port) = @_;	

	my ($query_handle, $fourbyte, $query, $return_handle, $sv_reply, $out);
	my @client_slurp;

 	# open up a UDP sock to the server
	$query_handle = IO::Socket::INET->new(Proto => 'udp', 
			PeerAddr => $host, 
			PeerPort => $port,
			Blocking => 0)
		or die "socket: $@";

	$fourbyte = "ÿÿÿÿ"; # yeah one day Ill figure out how to generate this properly
		$query = $fourbyte . "getinfo"; # supposedly the query to get all info

		$query_handle->send($query); # send our request to the server

		$return_handle = $query_handle->accept(); # accept data back from this socket

		# process header / cvars
		do {
			# take a line
			$query_handle->recv($_,4098);
			print;

			# at challenge line?
			if (m/\\challenge\\/) {
				m/.*fs_game\\([^\\]*).*g_match_score\\([^\\]*).*g_match_time\\([^\\]*).*g_needpass\\([^\\]*).*mapname\\([^\\]*).*sv_hostname\\([^\\]*).*sv_maxclients\\([^\\]*).*gametype\\([^\\]*).*clients\\([^\\]*).*/;

				# store for later
				$self->mod($1);
				$self->scores($2);
				$self->match_time($3);
				$self->need_pass($4);
				$self->map_name($5);
				$self->host_name($6);
				$self->max_clients($7);
				$self->game_type($8);
				$self->num_clients($9);
			}
		} until (m/\\challenge\\/);


		# slurp up the players
		do {
			$query_handle->recv($sv_reply,4098);
			print $sv_reply;
			$self->clients($sv_reply);
		} until ($sv_reply ne "\n");

		# test client store
		foreach ($self->clients) {
			print $_ . "\n";
		}

	close($query_handle);

}

sub PrintShortStatus() {
	$_ = $self->host_name . "\n" . $self->map_name . "\n" . $self->num_clients . "/" . $self->max_clients . "\n";
	print;
}

sub PrintToWeb {
	$_ = 



sub colorsToHtml() {
	my	@colors = ( "#000", # 0 , black
			"#F00", # 1, red
			"#0F0", # 2, green
			"#ff0", # 3, yellow
			"#00f", # 4, blue
			"#0ff", # 5, cyan
			"#f0f", # 6, purple
			"#fff", # 7, white
			"#ff8000", #8, orange
			"#808080", #9, grey
			);

	my $message = shift(@_);
	$message=~ s/\^(\d)/<font color="$colors[$1]">/g;
	return $message;
}

1;
