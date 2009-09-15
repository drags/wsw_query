#!/usr/bin/perl

use CGI ':standard';
use Warsow::Query;

$ketchup = new CGI;
$mustard = new Query;

print $ketchup->header;
print $ketchup->start_html('wswq');
foreach ($ketchup->param) {
	print $ketchup->param($_),"<br>\n";
}

$mustard->GetData('so.nuclearfallout.net','44400');

$lies = $mustard->GetFullStatus();
print "so umm " . $lies;
	
print end_html;
