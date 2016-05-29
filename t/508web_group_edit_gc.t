use lib qw(t/lib);
use GMSTest::Common 'approved_group';

use GMSTest::Database;
use Test::More;
use Test::MockModule;

# We don't want this right now.

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});


my $schema = need_database 'approved_group';

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

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get_ok("http://localhost/group/1/edit_gc", "Edit group contacts page works");

$ua->content_contains("test01", "group contact is in the page");

$ua->submit_form(
    fields => {
        action_1 => 'change',
        group_contacts => '1',
        status_1 => 'retired',
        primary_1 => 0,
    }
);

ok $ua->content_contains ("Successfully submitted the group contact change request. Please wait for staff to approve the change", "Submitting changes works");

$ua->get_ok("http://localhost/group/1/edit_gc", "Edit group contacts page works");

ok $ua->content_contains ("At least one of the group's contacts has a change request pending", "Pending change is recognised.");

ok $ua->content_contains ('name="primary_1" value="1"  />', "Primary checkbox isn't checked.");

ok $ua->content_contains ('"retired"  selected', 'retired checkbox is selected');

$ua->submit_form(
    fields => {
        action_2 => 'change',
        primary_2 => 1,
    }
);

ok $ua->content_contains ("Successfully submitted the group contact change request. Please wait for staff to approve the change", "Submitting changes works");

$ua->get_ok("http://localhost/group/1/edit_gc", "Edit group contacts page works");

ok $ua->content_contains ('name="primary_2" value="1"  checked  />', "Primary checkbox is checked.");

my $admin = $schema->resultset('Account')->find({ accountname => 'admin01' });
my $group = $schema->resultset('Group')->find({ group_name => 'group01' });

$group->change( $admin, 'workflow_change', { status => 'pending_staff' });

$ua->get_ok("http://localhost/group/1/edit_gc", "Edit group contacts page works");
$ua->content_contains("The group is not active", "Can't edit gcs of inactive groups");

done_testing;
