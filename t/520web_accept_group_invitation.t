use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $rs = $schema->resultset('GroupContact');
my $group_contact1 = $rs->find_by_id ("5_1");
my $group_contact2 = $rs->find_by_id ("5_4");

ok $group_contact1->status->is_invited, 'contact is invited';
ok $group_contact2->status->is_invited, 'contact is invited';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test04',
        password => 'tester04'
    }
);

$ua->content_contains("You are now logged in as test04", "Check we can log in");

$ua->get_ok("http://localhost/group", "Check group page works");

$ua->content_contains("group01", "Group is in the list");
$ua->content_contains("group04", "Group is in the list");

$ua->get_ok("http://localhost/group/1/view", "Check group page works");
$ua->content_contains("That group doesn't exist or you can't access it", "You can't see the details of a group you've been invited to.");

$ua->get_ok("http://localhost/group/1/invite/accept", "Accept invitation page works");
$ua->content_contains("Successfully accepted the group invitation", "Accept invitation page works.");

$group_contact1->discard_changes;

ok $group_contact1->status->is_pending_staff, 'status is pending_staff';
ok $group_contact1->last_change->change_type->is_workflow_change, 'change_type is workflow_change';

$ua->get_ok("http://localhost/group/1/view", "Check group page works");
$ua->content_contains("That group doesn't exist or you can't access it", "You can't see the details of a group you've been invited to.");

$ua->get_ok("http://localhost/group/4/invite/decline", "Decline invitation page works");
$ua->content_contains("Successfully declined the group invitation", "Decline invitation page works.");

$group_contact2->discard_changes;

ok $group_contact2->status->is_deleted, 'status is deleted';
ok $group_contact2->last_change->change_type->is_workflow_change, 'change_type is workflow_change';

$ua->get_ok("http://localhost/group/1/view", "Check group page works");

$ua->content_contains("That group doesn't exist or you can't access it", "You can't see the details of a group you've been invited to.");

done_testing;
