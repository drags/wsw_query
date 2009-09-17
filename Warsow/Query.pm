#!/usr/bin/perl 

package Query; 
use IO::Socket;
use strict;

sub new {
	my $self = {};
	$self->{MOD} = undef;
	$self->{SCORES} = undef;
	$self->{MATCH_TIME} = undef;
	$self->{NEED_PASS} = undef;
	$self->{MAP_NAME} = undef;
	$self->{HOST_NAME} = undef;
	$self->{HOST_ADDRESS} = undef;
	$self->{HOST_PORT} = undef;
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

sub host_address {
	my $self = shift;
	if (@_) { $self->{HOST_ADDRESS} = shift }
	return $self->{HOST_ADDRESS};
}

sub host_port {
	my $self = shift;
	if (@_) { $self->{HOST_PORT} = shift }
	return $self->{HOST_PORT};
}

sub host {
	my $self = shift;
	my ($host, $port) = @_;

	unless ($port) {
		if ($host =~ m/:/) {
			$host, $port = split(/:/, $host);
		} else {
			$port = "44400";
		}
	}
	
	$self->host_address($host);
	$self->host_port($port);

}

sub max_clients {
	my $self = shift;
	if (@_) { $self->{MAX_CLIENTS} = shift }
	return $self->{MAX_CLIENTS};
}

sub game_type {
	my $self = shift;

	my ($test);

	if (@_) { 
		$test = shift; 
	}
	
	my $game_types = { "ca" => "Clan Arena",
							 "dm" => "Deathmatch",
							 "tdm" => "Team Deathmatch",
							 "ctf" => "Capture The Flag",
							 "bomb" => "Bombing and Defuse",
							 "da"	=> "Duel Arena",
							 "race" => "Race"};
	if ($test) { 
		$self->{GAME_TYPE} = $test;
	}

	return $game_types->{ $self->{GAME_TYPE} };
}

sub short_game_type {
	my $self = shift;
	return $self->{GAME_TYPE};
}

sub num_clients {
	my $self = shift;
	if (@_) { $self->{NUM_CLIENTS} = shift }
	return $self->{NUM_CLIENTS};
}

sub clients {
	my $self = shift;
	my $players = {};
	if (@_) { push @{ $self->{CLIENTS} }, @_ };
	
	foreach (@{$self->{CLIENTS}}) {
		m/(\d*)\s(\d*)\s"([^"]*)"\s(\d*)/;
		my ($score, $ping, $name, $team) = ($1, $2, $3, $4);
		$players->{$name}->{'score'} = $score;
		$players->{$name}->{'ping'} = $ping;
		$players->{$name}->{'team'} = $team;
	}

	return $players;
}

sub clientlist {
	my $self = shift;

	my ($back, $score, $ping, $name, $team);

	$back = "<ul>\n";
	my $players = $self->clients;	
	if (keys %$players < 1) {
		$back .= qq#<li class="player">No players connected.</li>#;
	}
	foreach (keys %$players) {
		$back .= qq/<li class="player team/ . $players->{$_}->{'team'} . qq/">/ . &colorsToSpan($_) . qq/ <span class="playerscore">/  . $players->{$_}->{'score'} . "</span></li>\n";
	}

	$back .= "</ul>";

	return $back;
}

sub topscores {
	my $self = shift;

	my %scores;
	my %teams;
	my %players;

	my ($back);
		
	my $clients = $self->clients;
	foreach (keys %$clients) {
		my ($name, $score);
		$score = ($clients->{$_}->{'score'} == 9999)?$clients->{$_}->{'score'} * -1:$clients->{$_}->{'score'};
		$scores{$_} = $score;
		$teams{$_} = $clients->{$_}->{'team'};
	}

	if ($self->teamgame) {
		# $back = qq/<div class="score">/
	}

	my @top_players = sort {  $scores{$b} <=> $scores{$a} } keys %scores;

	$back .= "<ul>\n";

	my $huh = ((@top_players) < 2)?(@top_players):'2';

	foreach (0 .. $huh) {
		(@top_players == 0) && next;
		$back .= qq/<li class="player">/ . &colorsToSpan($top_players[$_]) . qq#<span class="playerscore"># .  $scores{ $top_players[$_] } . "</span></li>\n";
	}

	$back .= "</ul>\n";
	return $back;
}

sub teamgame {
	my $self = shift;
	my @team_game_types = qw/ca tdm ctf bomb ca duel ica itdm ictf ibomb ica iduel/;
	if (grep(/$self->{GAME_TYPE}/, @team_game_types)) {
		return 1;
	}
	return 0;
}

sub GetData {
	my $self = shift;
	my ($host, $port) = @_;	

	if ($host) { $self->host($host, $port); }

	$host = $self->host_address;
	$port = $self->host_port;

	unless ($host) {
		print "no host";
		return 0;
	}

	my ($query_handle, $fourbyte, $query, $return_handle, $sv_reply, $out);
	my @client_slurp;

	# open up a UDP sock to the server
	$query_handle = IO::Socket::INET->new(Proto => 'udp', 
			Blocking => 1,
			PeerAddr => $host, 
			PeerPort => $port)
		or die "socket: $@";

	$fourbyte = chr(255) . chr(255) . chr(255) . chr(255);
	$query = $fourbyte . "getstatus";

		$query_handle->send($query); # send our request to the server

		$query_handle->accept(); # accept data back from this socket

	# process header / cvars
	do {
	# take a line
		$_ = <$query_handle>;
		chomp; 
	} until (m/challenge/);

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


	# slurp up the players
	for (my $i = 0; $i < $self->num_clients; $i++) {
		$_ = <$query_handle>;
		chomp; 

		$self->clients($_);
	} 

	# test client store
#	foreach ($self->clients) {
#		print "Adding client\n";
#		print $_;
#	}

	close($query_handle);

	1;
}

sub PrintShortStatus() {
	my $self = shift;
	$_ = $self->host_name . "\n" . $self->map_name . "\n" . $self->num_clients . "/" . $self->max_clients . "\n";
	print;
}

sub GetFullStatus {
	my $self = shift;

	if (@_) { $self->host(@_[0],@_[1]); }
	
	unless ($self->GetData()) {
		print "no dice";
		return "Unable to connect to server.";
	}

	open TPL, "templates/default.tpl"; # TODO: other templates
	my @template = <TPL>;
	my $tpl = join ('',@template);

	my @tags = qw/HOST_NAME GAME_TYPE TOP_SCORES MAP_NAME CLIENTS MAX_PLAYERS CLIENT_LIST/;
	my @fills = (&colorsToSpan($self->host_name), $self->game_type, $self->topscores, $self->map_name, $self->num_clients, $self->max_clients, $self->clientlist);

	my $tagiter = 0;	
	foreach (@tags) {
		$tpl =~ s/##$_##/$fills[$tagiter]/g;
		$tagiter++;
	}

	return $tpl;
}

sub colorsToSpan() {
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

	my @parsed;

	my @message = split(/\n/, shift(@_));

	foreach (@message) {
		s/^([^\^]*)\^(\d)/\1<span class="carrot\2">/;
		s/\^(\d)/<\/span><span class="carrot\1">/g;
		if (m/span/) { s/$/<\/span>/; }
		unshift (@parsed, $_);
	}



	return join("\n", @parsed);
}

1;
