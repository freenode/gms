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
        approve_item => 1
    }
);

$ua->submit_form(
    fields => {
        action_6 => 'approve',
        action_7 => 'reject'
    }
);

my $schema = GMS::Schema->do_connect;

my $rs = $schema->resultset('ChannelNamespace');

my $ns6 = $rs->find({ id => 6 });
my $ns7 = $rs->find({ id => 7 });

ok $ns6->status->is_active;
ok $ns7->status->is_deleted;

ok $ns6->active_change->change_type->is_admin;
ok $ns7->active_change->change_type->is_admin;

done_testing;
