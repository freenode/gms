use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $rs = $schema->resultset('GroupContact');

my $gc2_1 = $rs->find_by_id ('2_1');
my $gc2_4 = $rs->find_by_id ('2_4');

ok $gc2_1->status->is_pending_staff, 'group contact is pending_staff';
ok $gc2_4->status->is_pending_staff, 'group contact is pending_staff';

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

$ua->get_ok("http://localhost/admin/approve_new_gc", "Group Contact approval page works");

$ua->submit_form(
    fields => {
        action_2_1 => 'approve',
        action_2_4 => 'reject'
    }
);

$gc2_1->discard_changes;
$gc2_4->discard_changes;

ok $gc2_1->active_change->status->is_active, 'approved contact is active';
ok $gc2_4->active_change->status->is_deleted, 'rejected contact is deleted';

done_testing;
