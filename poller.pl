#!/usr/bin/perl -w
use Warsow::Query;
use File::Basename;
use strict;

my $now = time;
my $q = new Query;

$q->host_address('so.nuclearfallout.net');
$q->host_port('44400');
$q->query($hostname, $port);

my $dir = dirname($0);
open LOG, '>>' . $dir . '/players.hist' or die "Unable to open logfile, chump.\n";

my $numclients = $q->num_clients;
my $mapname = $q->map_name;

print LOG $now . ":" . $numclients . ":" . $mapname . "\n";

close LOG;
