#!/usr/bin/perl 

package Poller; 
use strict;

use Warsow::Query;
use File::Basename;
use RRD::Simple;

sub new {
	my $self = {};
	$self->{HOST} = undef;
	$self->{PORT} = undef;
	$self->{QUERY} = undef;
	$self->{RRD} = undef;

	bless($self);
	return $self;
}

# set host address if valid input supplied, always returns current host address
sub host_address {
	my $self = shift;

	if (@_) {
		my $host = shift;
		
		unless (defined($host)) { return $self->{HOST} }
		$host =~ s/\s*//g;

		if ($host =~ m/\S+/) {
			$self->{HOST} = $host;
		}

	}

	return $self->{HOST};
}

# set port address if valid input supplied, always returns current port address
sub host_port {
	my $self = shift;
	my $port = '';

	if (@_) {
		$port = shift;	

		unless (defined($port)) { return $self->{PORT} }
		$port =~ s/\s*//g;

		if ($port =~ m/\d+/) {
			$self->{PORT} = $port;
		}
	}
	return $self->{PORT};
}

# return any key specified from self hash
# TODO: change ivar in rras to pass references
sub query {
	my $self = shift;
	if (@_) { $self->{QUERY} = shift } 
	return $self->{QUERY};

}

# setup any RRAs to be tracked and graphed here.. all servers get all RRAs listed here
sub getRRAs {
	my $self = shift;
	my $rras = {};

	$rras->{'players'} = { 
		ivar => 'num_clients',
		filename => 'players.rrd',
		period => '3years',
		source_name => 'players',
		source_dstype =>  'GAUGE' 
	};

	return $rras;
}

# directory in same directory as script where data is stored
# TODO: change to act like other accessors and update if valid input given, will
# allow script to live seperate of data
sub getWorkingDir {
	return dirname($0) . "/server_data/";
}

# standardize directory to dump current servers data into
sub DataDir {
	my $self = shift;
	my ($host, $port) = (@_);

	$host = $self->host_address($host);
	$port = $self->host_port($port);

	unless ($self->host_address && $self->host_port) {
		return undef;
	}

	my $datadir = $self->getWorkingDir . $self->host_address . "-" . $self->host_port . "/";
	return $datadir;
}

# create RRDs for each RRA
sub createRRDs {
	my $self = shift;
	my ($host, $port) = @_;

	# set and retrieve address info
	$host = $self->host_address($host);
	$port = $self->host_port($port);

	my $rras = $self->getRRAs;
	my $datadir = $self->DataDir;

	# make sure we have a directory for the data and it is writable by us
	unless ($datadir && -w $datadir) {
		print "Unable to get data directory.\n";
		return 0;
	}

	unless( -d $datadir) {
		mkdir $datadir
			or die "Unable to create new data directory for host " . $self->host_address . ":" . $self->host_port . ".\n";
	}

	# create RRD with default settings and setup first source, if RRD exists, add_source
	foreach (keys %$rras) {
		my $rrd = RRD::Simple->new( 
			file => $datadir . $rras->{$_}{'filename'}, 
			default_dstype => "GAUGE"
		);

		if ( -e $datadir . $rras->{$_}{'filename'} ) {
			$rrd->add_source($rras->{$_}{'source_name'} => $rras->{$_}{'source_dstype'});
		} else {
			$rrd -> create(
				$rras->{$_}{'period'}, 
				$rras->{$_}{'source_name'} => $rras->{$_}{'source_dstype'}
			);
		}
	}
}

# use get_data to update the Query and update all defined RRAs using that data
sub updateServer {
	my $self = shift;
	my ($host, $port) = @_;

	# set and retrieve address info
	$host = $self->host_address($host);
	$port = $self->host_port($port);

	unless ($host && $port) {
		die "Please pass host and port to updateServer.\n";
	}

	my $rras = $self->getRRAs;
	my $datadir = $self->DataDir;

	my $q = new Query;
	unless($q->get_data($host, $port)) {
		return "Unable to connect to server.<br>\n";
	}

	foreach (keys %$rras) {
		# rrd handler
		my $rrd = RRD::Simple->new( 
			file => $datadir . $rras->{$_}{'filename'}
		); 

		# if RRD doesn't exist yet, create
		unless ( -e $datadir  . $rras->{$_}{'filename'} ) {
			$self->createRRDs($host, $port);
		}
		
		# grab data from query and update RRA
		my $data = $q->get($rras->{$_}{'ivar'});
		print "Updating " . $rras->{$_}{'source_name'} . " with value " . $data . "\n";
		$rrd->update($rras->{$_}{'source_name'} => $data);
	}
	1;
}

sub updateGraphs {
	my $self = shift;
	my ($host, $port, @periods) = @_;

	# unless periods has more than 0 elements, process short time periods
	unless (@periods) {
		@periods = ('hour','6hour','12hour','day','week','month');
	}

	# set and retrieve address info
	$host = $self->host_address($host);
	$port = $self->host_port($port);

	
	unless ($host && $port) {
		die "Please pass host and port to updateRRDs.\n";
	}

	my $rras = $self->getRRAs;
	my $datadir = $self->DataDir;

	foreach (keys %$rras) {
		# rrd handler
		my $rrd = RRD::Simple->new( 
			file => $datadir . $rras->{$_}{'filename'}
		); 

		# if rrd isn't created yet, nothing to graph
		unless ( -e $datadir . $rras->{$_}{'filename'}) {
			die "Unable to locate RRD file at " . $datadir . $rras->{$_}{'filename'} . ".\nMake sure to run updateServer before running updateGraphs.\n";
		}

		# generate new graphs
		$rrd->graph(
			destination => $datadir, 
			periods => [ @periods ], 
			sources => $rras->{$_}{'source_name'}, 
			width => 419,
			height => 108,
			title => $rras->{$_}{'source_name'},
			source_drawtypes => { players => 'AREA' },
			source_colors => [ qw(00ff00) ],
			extended_legend => 1
		);
	}
}

1;
