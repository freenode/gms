use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockObject;
use Test::MockModule;

# We don't want this right now.

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});


our $schema = need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockGroup = new Test::MockModule('GMS::Domain::Group');
$mockGroup->mock ('new',
    sub {
        my (undef, undef, $group) = @_;
        $group;
    });

my $mockSession = new Test::MockModule ('GMS::Web::Model::Atheme');

$mockSession->mock ('session', sub {
    });

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });

my $mockAtheme = new Test::MockObject;

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

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

$ua->post_ok ('http://localhost/json/admin/approve_groups/submit/',
    {
        approve_groups  => '2 3',
        action_3 => 'approve',
    }
);

$ua->post_ok ('http://localhost/json/admin/approve_groups/submit/',
    {
        approve_groups => '2',
        action_2 => 'verify',
    }
);

my $schema = GMS::Schema->do_connect;

my $rs = $schema->resultset('Group');

my $group2 = $rs->find({ id => 2 });
my $group3 = $rs->find({ id => 3 });

ok $group2->status->is_verified, 'verified group is verified';
ok $group3->status->is_active, 'approved group is active';

my @channel_namespaces = $group2->channel_namespaces->search({}, { order_by => 'id' });
my @cloak_namespaces = $group2->cloak_namespaces->search({}, { order_by => 'id' });

ok $channel_namespaces[0]->status eq 'pending_staff';
ok $channel_namespaces[1]->status eq 'active';
ok $channel_namespaces[2]->status eq 'pending_staff';

ok $cloak_namespaces[0]->status eq 'active';
ok $cloak_namespaces[1]->status eq 'pending_staff';

$ua->post_ok ('http://localhost/json/admin/approve_groups/submit/',
    {
        approve_groups => '2',
        action_2 => 'reject',
    }
);

$group2->discard_changes;
@channel_namespaces = $group2->channel_namespaces;
@cloak_namespaces = $group2->cloak_namespaces;

ok $channel_namespaces[0]->status eq 'deleted', 'all namespaces are deleted';
ok $channel_namespaces[1]->status eq 'deleted', 'all namespaces are deleted';
ok $channel_namespaces[2]->status eq 'deleted', 'all namespaces are deleted';

ok $cloak_namespaces[0]->status eq 'deleted', 'all namespaces are deleted';
ok $cloak_namespaces[1]->status eq 'deleted', 'all namespaces are deleted';


ok $group2->status->is_deleted, 'group is now deleted';

$ua->post_ok ('http://localhost/json/admin/approve_groups/submit/',
    {
        action_3 => 'approve',
        approve_groups => '3'
    }
);

$ua->content_contains ("Can't approve a group that isn't verified or pending verification", "Can't approve a group that isn't verified or pending verification");


$ua->post_ok ('http://localhost/json/admin/approve_groups/submit/',
    {
        action_3 => 'reject',
        approve_groups => '3'
    }
);

$ua->content_contains ("Can't reject a group not pending approval", "Can't reject a group not pending approval");

done_testing;
