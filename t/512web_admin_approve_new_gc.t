use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::More;
use Test::MockModule;
use Test::MockObject;

# We don't want this right now.

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});

our $schema = need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });

my $mockAtheme = new Test::MockObject;

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

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

$ua->post_ok('http://localhost/json/admin/approve_new_gc/submit',
    {
        approve_contacts => '2_1 2_4',
        action_2_4 => 'reject'
    }
);

$ua->post_ok('http://localhost/json/admin/approve_new_gc/submit',
    {
        approve_contacts => '2_1',
        action_2_1 => 'approve'
    }
);

$gc2_1->discard_changes;
$gc2_4->discard_changes;

ok $gc2_1->active_change->status->is_active, 'approved contact is active';
ok $gc2_4->active_change->status->is_deleted, 'rejected contact is deleted';

$ua->post_ok('http://localhost/json/admin/approve_new_gc/submit',
    {
        approve_contacts => '2_1',
        action_2_1 => 'approve'
    }
);

$ua->content_contains ("Can't approve a group contact not pending approval");

$ua->post_ok('http://localhost/json/admin/approve_new_gc/submit',
    {
        approve_contacts => '2_1',
        action_2_1 => 'reject'
    }
);

$ua->content_contains ("Can't reject a group contact not pending approval");

done_testing;
