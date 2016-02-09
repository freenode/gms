# When a group deletes a channel/cloak namespace,
# then (the same group, or another group) requests it back,
# and at the same time another group tries
# to get the same namespace, a conflict can exist.
# GMS notifies the group contact of the latter group
# of that, and has them confirm they want to create
# a conflict. Admins are then responsible to fix it.

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;

# We don't want this right now.

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});


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

my $mockSession = new Test::MockModule ('GMS::Web::Model::Atheme');

$mockSession->mock ('session', sub {
    });

my $rs = $schema->resultset('ChannelNamespace');

my $ns = $rs->find({ namespace => 'new_namespace_3' });

ok $ns->status->is_deleted, 'active change is deleted';
ok $ns->last_change->change_type->is_request, 'last change is request';
ok $ns->last_change->status->is_active, 'requested status is active';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get_ok("http://localhost/group/4/edit_channel_namespaces", "Check channel namespace page works");

$ua->submit_form(
    fields => {
        namespace => 'new_namespace_3'
    }
);

$ua->content_contains("Another group has requested that namespace", "Catch conflicting request");

$ua->submit_form(
    fields => {
        namespace => 'new_namespace_3',
        do_confirm => 1
    }
);

$ua->content_contains("Successfully submitted the channel namespace change request. Please wait for staff to approve the change", "Updating the namespace works");

ok $ns->status->is_deleted, 'active change is still deleted';
ok $ns->last_change->change_type->is_request, 'last change is request';

done_testing;
