use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->get_ok("http://localhost/admin/approve_namespaces", "Namespace approval page works");

$ua->submit_form(
    fields => {
        approve_item => 2
    }
);

$ua->submit_form(
    fields => {
        action_3 => 'approve',
        action_4 => 'reject'
    }
);

my $schema = GMS::Schema->do_connect;

my $rs = $schema->resultset('CloakNamespace');

my $ns3 = $rs->find({ id => 3 });
my $ns4 = $rs->find({ id => 4 });

ok $ns3->status->is_active;
ok $ns4->status->is_deleted;

ok $ns3->active_change->change_type->is_admin;
ok $ns4->active_change->change_type->is_admin;

done_testing;
