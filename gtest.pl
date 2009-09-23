use lib '/var/www/hurr/htdocs/wsw_query/';
use Warsow::Poller;

my $poller = new Poller;

$poller->updateGraphs('216.52.143.228','44400');
$poller->updateGraphs('66.150.214.231','44400');
$poller->updateGraphs('75.102.38.26','44400');
$poller->updateGraphs('74.86.100.40','44451');
$poller->updateGraphs('74.86.100.40','44453');
$poller->updateGraphs('78.46.73.70','44400');
$poller->updateGraphs('89.248.165.13','44400');
$poller->updateGraphs('so.nuclearfallout.net','44400');
