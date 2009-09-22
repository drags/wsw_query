use lib '/var/www/hurr/htdocs/wsw_query/';
use Warsow::Poller;

my $poller = new Poller;

$poller->updateServer('so.nuclearfallout.net','44400');
$poller->updateServer('78.46.73.70','44400');
$poller->updateServer('89.248.165.13','44400');
