#!/usr/bin/perl 

package Query; 
use lib '/var/www/hurr/htdocs/wsw_query/';
use Warsow::Poller;
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
	$self->{TEMPLATE} = 'templates/default.tpl';
	bless ($self);
	return $self;
}

# get a key
sub get {
	my $self = shift;
	my ($key) = @_;

	$key =~ s/(.*)/\U$1/g;

	# if we have one
	if (defined ($self->{$key}) ) {
		return $self->{$key};
	}
	return undef;
}

# accessor functions, input validated functions to store/retrieve keys of self hash
sub host_name {
	my $self = shift;
	if (@_) { $self->{HOST_NAME} = shift }
	return $self->{HOST_NAME};
}

sub map_name {
	my $self = shift;
	if (@_) { $self->{MAP_NAME} = shift }
	return $self->{MAP_NAME};
}

sub template {
	my $self = shift;
	if (@_) { $self->{TEMPLATE} = shift }
	return $self->{TEMPLATE};
}
sub mod {
	my $self = shift;
	if (@_) { $self->{MOD} = shift }
	return $self->{MOD};
}

sub match_score {
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

sub host_address {
	my $self = shift;

	if (@_) {
		my $host = shift;

		if ($host) {
			$host =~ s/\s*//g;
			$self->{HOST} = $host;
		}
	}
	return $self->{HOST};
}

sub host_port {
	my $self = shift;
	my $port = '';

	if (@_) {
		$port = shift;	

		if ($port && $port =~ m/\d+/) {
			$port =~ s/\s*//g;
			$self->{PORT} = $port;
		}
	}
	return $self->{PORT};
}

sub host {
	my $self = shift;
	my ($host, $port) = @_;

	unless ($port) {
		if ($host =~ m/:/) {
			($host, $port) = split(/:/, $host);
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

	if (@_) { 
		$self->{GAME_TYPE} = shift;
	}
	return $self->{GAME_TYPE};
}

sub num_clients {
	my $self = shift;
	if (@_) { $self->{NUM_CLIENTS} = shift }
	return $self->{NUM_CLIENTS};
}

sub clients {
	my $self = shift;

	if (@_) {  
		foreach (@_) {
			push (@{$self->{CLIENTS}}, $_);
		}
	}

	return $self->{CLIENTS};
}
# END accessor functions


# translate gametype into long name
sub game_long_name {
	my $self = shift;

	my $game_types = { "ca" => "Clan Arena",
							 "dm" => "Deathmatch",
							 "tdm" => "Team Deathmatch",
							 "ctf" => "Capture The Flag",
							 "bomb" => "Bombing and Defuse",
							 "da"	=> "Duel Arena",
							 "race" => "Race"};

	return $game_types->{ $self->{GAME_TYPE} };
}

# client hash for simpler access
sub client_hash {
	my $self = shift;
	my $players = {};

	foreach (@{$self->{CLIENTS}}) {
		m/(\d*)\s(\d*)\s"([^"]*)"\s(\d*)/;
		my ($score, $ping, $name, $team) = ($1, $2, $3, $4);
		$players->{$name}->{'score'} = $score;
		$players->{$name}->{'ping'} = $ping;
		$players->{$name}->{'team'} = $team;
	}

	return $players;
}


# client list for use in template output
sub t_client_list {
	my $self = shift;
	my ($msg, $score, $ping, $name, $team);

	my $players = $self->client_hash;	
	if (keys %$players == 0) {
		$msg .= qq#<div class="player">No players connected.</div>#;
	}
	foreach (keys %$players) {
		$msg .= qq/<div class="pline team/ 
					. $players->{$_}->{'team'} 
					. qq/">/ 
					. qq/<div class="player">/ 
					. &colorsToSpan($_) 
					. qq/<\/div><div class="playerscore">/  
					. $players->{$_}->{'score'} 
					. qq#</div></div>#;
	}
	return $msg;
}

# locate levelshot if possible, otherwise return path to unknown level shot image
sub levelshot {
	my $self = shift;

	my $map = $self->{MAP_NAME};
	my $img = ( -e "levelshots/" . $map . ".jpg")?"levelshots/" . $map . ".jpg":"levelshots/unknown.jpg";

	return $img;
}

# return current team scores for use in template
sub team_scores {
	1;	
}

# return top 3 player scores
sub top_scores {
	my $self = shift;

	my %scores;
	my %teams;
	my %players;

	my ($msg);
		
	my $clients = $self->client_hash;
	foreach (keys %$clients) {
		my $score = ($clients->{$_}->{'score'} == 9999)?$clients->{$_}->{'score'} * -1:$clients->{$_}->{'score'};
		$scores{$_} = $score;
		$teams{$_} = $clients->{$_}->{'team'};
	}

	my @top_players = sort {  $scores{$b} <=> $scores{$a} } keys %scores;

	my $huh = ((@top_players) < 2)?(@top_players):'3';

	foreach (0 .. $huh-1) {
		(@top_players == 0) && next;
		$msg .= qq/<div class="pline team/ 
				. $teams{$_} 
				. qq/"><div class="player">/ 
				. &colorsToSpan($top_players[$_]) 
				. qq#</div><div class="playerscore"># 
				.  $scores{ $top_players[$_] } 
				. qq#</div></div>\n#;
	}
	return $msg;
}

# boolean for whether current gametype is teamgame
sub teamgame {
	my $self = shift;
	my @team_game_types = qw/ca tdm ctf bomb ca duel ica itdm ictf ibomb ica iduel/;
	if (grep(/$self->{GAME_TYPE}/, @team_game_types)) {
		return 1;
	}
	return undef;
}

# initiates connection and returns query handle if successful, undef it not
sub connect {
	my $self = shift;
	my $query_handle;

	# open up a UDP sock to the server
	$query_handle = IO::Socket::INET->new(
			Proto => 'udp', 
			Blocking => 1,
			PeerAddr => $self->host_address, 
			PeerPort => $self->host_port
			) or return undef;
	return $query_handle;
}

# send UDP query to server for getinfo, parse reply into object hash
# requires: nadda
# accepts: host/port
# returns: undef on fail, 1 on update
sub get_data {
	my $self = shift;
	my ($host, $port) = @_;	


	$host = $self->host_address($host);
	$port = $self->host_port($port);

	# must have a host by now
	unless ($host) {
		warn "No host.\n";
		return undef;
	}

	my ($query_handle, $fourbyte, $query, $return_handle, $sv_reply, $out);
	my @client_lines;

	$query_handle = $self->connect;

	# returns undef on fail
	unless ($query_handle) { return undef }

	# query
	$fourbyte = chr(255) x 4;
	$query = $fourbyte . "getstatus";
	$query_handle->send($query); # send our request to the server


	# process header / cvars
	do {
	# take a line
		eval {
			local $SIG{ALRM} = sub { die 0 };
			alarm(4);
			$_ = <$query_handle>;
			alarm(0);
			1;
		} or return undef;
		

		# if not defined, no response, assume dead connection
		unless(defined) { return undef };
		chomp; 
	} until (m/challenge/);

	# at challenge line?
	if (m/\\challenge\\/) {
		m/.*fs_game\\([^\\]*).*g_match_score\\([^\\]*).*g_match_time\\([^\\]*).*g_needpass\\([^\\]*).*mapname\\([^\\]*).*sv_hostname\\([^\\]*).*sv_maxclients\\([^\\]*).*gametype\\([^\\]*).*clients\\([^\\]*).*/;

	# store info into object
		$self->mod($1);
		$self->match_score($2);
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
		chomp($_ = <$query_handle>);

		push @client_lines, $_;

		# build object client array a line at a time.. 
	} 
		
	$self->clients(@client_lines);

	close($query_handle);

	return 1;
}

# for console output
sub get_short_status() {
	my $self = shift;

	if (@_) { $self->host($_[0], $_[1]); }
	
	unless ($self->get_data()) {
		return "Unable to connect to server.<br>\n";
	}

	my $msg = $self->host_name . "\n" . $self->map_name . "\n" . $self->num_clients . "/" . $self->max_clients . "\n";
	return $msg;
}

# calls get_data, uses result to fill template and return
sub get_full_status {
	my $self = shift;

	if (@_) { $self->host($_[0], $_[1]); }
	
	unless ($self->get_data()) {
		return "Unable to connect to server.<br>\n";
	}

	my $template_file = $self->template;
	open TPL, "<" . $template_file; # TODO: other templates
	my @template = <TPL>;
	my $tpl = join ('',@template);

	my @tags = qw/HOST_NAME HOST_ADDRESS HOST_PORT GAME_TYPE TOP_SCORES MAP_NAME CLIENTS MAX_PLAYERS CLIENT_LIST LEVEL_SHOT GRAPHS/;
	my @fills = (&colorsToSpan($self->host_name), $self->host_address, $self->host_port, $self->game_long_name, $self->top_scores, $self->map_name, $self->num_clients, $self->max_clients, $self->t_client_list, $self->levelshot, $self->getGraphs);

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
		s/^([^\^]*)\^(\d)/$1<span class="carrot$2">/;
		s/\^(\d)/<\/span><span class="carrot$1">/g;
		if (m/span/) { s/$/<\/span>/; }
		unshift (@parsed, $_);
	}



	return join("\n", @parsed);
}

# graph div if they're data on hand
# TODO: cycle RRAs and -e filename
sub getGraphs {
	my $self = shift;

	my $p = new Poller;

	my ($host, $port) = (@_);

	$host = $self->host_address($host);
	$port = $self->host_port($port);


	unless ( -d $p->DataDir($host, $port) )  {
		return "";
	}

	my $msg .= "	<div class=\"graphs\">
				<img title=\"daily\" src=\"server_data/" . $self->host_address . "-" . $self->host_port . "/players-daily.png\"></img><br>
				<img title=\"weekly\" src=\"server_data/" . $self->host_address . "-" . $self->host_port . "/players-weekly.png\"></img><br>
			</div>";

	return $msg;
}

1;
