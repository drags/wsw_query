#!/usr/bin/perl -w
use lib '/var/www/hurr/htdocs/wsw_query/';
use Warsow::Query;
use File::Basename;
use strict;


my $hostname = 'so.nuclearfallout.net';
my $port = '44400';

my $dir = dirname($0);
open LOG, '>>' . $dir . '/players.hist' or die "Unable to open logfile, chump.\n";

my $q = new Query;

my $now = time;

$q->GetData($hostname, $port);

my $numclients = $q->num_clients;
my $mapname = $q->map_name;

print LOG $now . ":" . $numclients . ":" . $mapname . "\n";

#use rrd simple to fill rrd
#badass rrd create script
#find better way to log 
#(+graph, ugh)
