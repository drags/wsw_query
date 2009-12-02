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
print '<div class="container">';
unless ($ketchup->param('server')) {
	open NOS, "<templates/noserver.tpl";
	my @template = <NOS>;
	my $tpl = join ('',@template);
	print $tpl;
	print end_html;
	print '</div>';
	exit;
}

#setup host
$mustard->host_address($ketchup->param('server'));
$mustard->host_port($ketchup->param('port'));
$mustard->template('default');
$mustard->query();

#render the template
print $mustard->render_template($ketchup->param('server'),$ketchup->param('port'));


print '</div>';
print end_html;
