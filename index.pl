#!/usr/bin/perl

use CGI ':standard';
use Warsow::Query;

#spicy objectsa
$ketchup = new CGI;
$mustard = new Query;

#spit it out
print $ketchup->header;
print $ketchup->start_html(-title => 'qtrl', -style => { -src => 'css/wsw_query.css'});

#server input
unless ($ketchup->param('server')) {
	open NOS, "<templates/noserver.tpl";
	my @template = <NOS>;
	my $tpl = join ('',@template);
	print $tpl;
	print end_html;
	exit;
}

#get server info and print
print $mustard->GetFullStatus($ketchup->param('server'),$ketchup->param('port'));

print end_html;
