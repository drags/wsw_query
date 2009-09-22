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

sub host_address {
	my $self = shift;

	if (@_) {
		my ($host) = @_;
		
		$host =~ s/\s*//g;

		$self->{HOST} = $host;
	}

	return $self->{HOST};
}

sub host_port {
	my $self = shift;

	if (@_) {
		my ($port) = @_;	
		$port =~ s/\s*//g;

		if ($port =~ m/\D/) {
			return 0;
		}

		$self->{PORT} = $port;
	}

	return $self->{PORT};
}

sub query {
	my $self = shift;
	if (@_) { $self->{QUERY} = shift } 
	return $self->{QUERY};

}

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

sub getWorkingDir {
	return dirname($0) . "/server_data/";
}

sub DataDir {
	my $self = shift;

	unless ($self->host_address && $self->host_port) {
		return undef;
	}

	my $datadir = $self->getWorkingDir . $self->host_address . "-" . $self->host_port . "/";
	return $datadir;
}

sub createRRDs {
	my $self = shift;
	my ($host, $port) = @_;

	# set and retrieve address info
	$host = $self->host_address($host);
	$port = $self->host_port($port);

	my $rras = $self->getRRAs;
	my $datadir = $self->DataDir;

	unless ($datadir) {
		print "Unable to get data directory.\n";
		return 0;
	}

	unless( -d $datadir) {
		mkdir $datadir
			or die "Unable to create new data directory for host " . $self->host_address . ":" . $self->host_port . ".\n";
	}

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

sub updateServer {
	my $self = shift;
	my ($host, $port) = @_;

	# set and retrieve address info
	$host = $self->host_address($host);
	$port = $self->host_port($port);

	unless ($host && $port) {
		die "Please pass host and port to updateRRDs.\n";
	}

	my $rras = $self->getRRAs;
	my $datadir = $self->DataDir;

	my $q = new Query;
	$q->GetData($host, $port);

	foreach (keys %$rras) {
		my $rrd = RRD::Simple->new( 
			file => $datadir . $rras->{$_}{'filename'}
		); 

		unless ( -e $datadir  . $rras->{$_}{'filename'} ) {
			$self->createRRDs($host, $port);
		}
		
		my $data = $q->get($rras->{$_}{'ivar'});
		print "Updating " . $rras->{$_}{'source_name'} . " with value " . $data . "\n";
		$rrd->update($rras->{$_}{'source_name'} => $data);

	}
}

sub updateGraphs {
	my $self = shift;
	my ($host, $port, @periods) = @_;

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
	print "Datadir is " . $datadir . "\n";

	foreach (keys %$rras) {
		my $rrd = RRD::Simple->new( 
			file => $datadir . $rras->{$_}{'filename'}
		); 

		unless ( -e $datadir . $rras->{$_}{'filename'}) {
			die "Unable to locate RRD file at " . $datadir . $rras->{$_}{'filename'} . ".\n";
		}

		$rrd->graph(
			destination => $datadir, 
			periods => [ @periods ], 
			sources => $rras->{$_}{'source_name'} 
		);
	}
}

1;
