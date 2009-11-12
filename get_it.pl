#!/usr/bin/perl -w
use Warsow::Query;
use Data::Dumper;
use IO::Socket;

$gopher = Query->new();

$gopher->GetData('so.nuclearfallout.net','44400');

print $gopher->get_full_status();
