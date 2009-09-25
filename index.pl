#!/usr/bin/perl

use CGI ':standard';
use Warsow::Query;

$ketchup = new CGI;
$mustard = new Query;

print $ketchup->header;
print $ketchup->start_html(-title => 'wswq', -style => { -src => 'css/wsw_query.css'});

unless ($ketchup->param('server')) {
	print "Sorry, no server has been specified. Please add server=address.of.server to query string.<br>\n";
	print end_html;
	exit;
}

print $mustard->GetFullStatus($ketchup->param('server'),$ketchup->param('port'));

print end_html;
