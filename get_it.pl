#!/usr/bin/perl -w
use Warsow::Query;

$gopher = Query->new();

$gopher->GetData('so.nuclearfallout.net','44400');

$gopher->PrintShortStatus();
