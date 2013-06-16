use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $mockGroup = new Test::MockModule('GMS::Domain::Group');
$mockGroup->mock ('new',
    sub {
        my (undef, undef, $group) = @_;
        $group;
    });

my $rs = $schema->resultset('Group');

my $group = $rs->find({ group_name => 'deleted_group' });

ok $group->status->is_deleted, 'active change is deleted';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get_ok("http://localhost/group/new", "Check new group page works.");

$ua->submit_form(
    fields => {
        group_name => 'deleted_group',
        group_url => 'http://localhost/',
        channel_namespace => 'test01'
    }
);

$ua->content_contains("The group deleted_group has been successfully added", "Adding the group works");

$group = $rs->find({ 'group_name' => 'deleted_group', 'deleted' => 0 }); # The new group is added as a new table row.

ok $group, 'Group exists';
ok $group->last_change->status->is_pending_web, 'Adding the group works';
ok !$group->last_change->status->is_deleted, 'Group is not deleted';

done_testing;
