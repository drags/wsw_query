#!/usr/bin/perl -w
use IO::Socket;
use Data::Dumper;


package wsw_query {
	use strict;

	our $mod = "";
	our $scores = "";
	our $match_time = "";
	our $need_pass = "";
	our $map_name = "";
	our $host_name = "";
	our $max_clients = "";
	our $game_type = "";
	our $num_clients = "";
	our @clients qw//;

	sub GetData {
		($host, $port) = @_;	

		# open up a UDP sock to the server
		$query_handle = IO::Socket::INET->new(Proto => 'udp', 
				PeerAddr => $host, 
				PeerPort => $port) 
			or die "socket: $@";

		$fourbyte = "ÿÿÿÿ"; # yeah one day Ill figure out how to generate this properly
		$query = $fourbyte . "getinfo"; # supposedly the query to get all info

		$query_handle->send($query); # send our request to the server

		$return_handle = $query_handle->accept(); # accept data back from this socket

		# process return data
		while ($query_handle->recv($sv_reply,4098)) {
			# fugly regex to extract infoz
			$sv_reply=~ m/.*fs_game\\([^\\]*).*g_match_score\\([^\\]*).*g_match_time\\([^\\]*).*g_needpass\\([^\\]*).*mapname\\([^\\]*).*sv_hostname\\([^\\]*).*sv_maxclients\\([^\\]*).*gametype\\([^\\]*).*clients\\([^\\]*).*/;
# some proper names and storage
			($self->$mod, $self->$scores, $self->$match_time, $self->$need_pass, $self->$map_name, $self->$host_name, $self->$max_clients, $self->$game_type, $self->$num_clients) = ($1, $2, $3, $4, $5, $6, $7, $8, $9);

			$out = $host_name . "\n" . $scores . "\n" . $map_name . "\n" . $num_clients . "/" . $max_clients;
			$out = &colorsToHtml($out);
			print $out . "\n\n\n";
		}

		close($query_handle);
	}

	sub shortStatus() {

	}

	sub colorsToHtml() {
		@colors = ( "#000", # 0 , black
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

		$message = shift(@_);
		$message=~ s/\^(\d)/<font color="$colors[$1]">/g;
		return $message;
	}

}
