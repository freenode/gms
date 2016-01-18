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

our $schema = need_database 'approved_group';

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

$ua->get_ok("http://localhost/group/1/invite", "Invitation page works");

my $mock = new Test::MockObject;

$mock->mock ('find_by_name', sub {
        my ( $self, $name ) = @_;

        return $schema->resultset('Account')->find ({ accountname => $name });
    });

my $mockModel = new Test::MockModule ('GMS::Web::Model::Accounts');

$mockModel->mock ('ACCEPT_CONTEXT', sub {
        return $mock;
    });

$ua->submit_form (
    fields => {
        contact => 'test03'
    }
);

$ua->content_contains("Successfully invited the contact", "Invitation works");

$ua->get("http://localhost/group/1/view");

$ua->text_like(qr/Pending Contacts.*test03/, "You can see pending contacts.");

my $schema = GMS::Schema->do_connect;

my $group = $schema->resultset('Group')->find({ group_name => 'group01' });
ok($group, "Check group exists");

is $group->group_contacts->count, 3, "Group has three contacts";
is $group->active_group_contacts->count, 2, "Group has two active contacts - invited contact isn't active";

$ua->get_ok("http://localhost/group/1/invite", "Invitation page works");

$ua->submit_form (
    fields => {
        contact => 'test04'
    }
);

$ua->content_contains("This user does not exist or has no contact information defined", "Inviting a user with no contact info fails");

$ua->get_ok("http://localhost/group/1/invite", "Invitation page works");

$ua->submit_form (
    fields => {
        contact => 'doesnt_exist'
    }
);

$ua->content_contains("This user does not exist or has no contact information defined", "Inviting a user that doesn't exist fails");

$ua->get("http://localhost/logout");
$ua->get_ok("http://localhost/login", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test03',
        password => 'tester03'
    }
);

$ua->content_contains("You are now logged in as test03", "Check we can log in");

$ua->get_ok("http://localhost/group/1/invite/accept", "Accept invitation page works");
$ua->content_contains("Successfully accepted the group invitation", "Accept invitation page works.");

$ua->get("http://localhost/logout");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get("http://localhost/group/1/view");

$ua->text_like(qr/Pending Contacts.*test03/, "Pending staff contacts still show.");

$admin = $schema->resultset('Account')->find({ accountname => 'admin01' });
$group->change( $admin, 'workflow_change', { status => 'pending_staff' });


$ua->get_ok("http://localhost/group/1/invite", "Invitation page works");
$ua->content_contains("The group is not active.", "Inactive groups can't invite");

$ua->get("http://localhost/logout");
$ua->get_ok("http://localhost/login", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test03',
        password => 'tester03'
    }
);

$ua->content_contains("You are now logged in as test03", "Check we can log in");

$ua->get_ok("http://localhost/group/1/invite/accept", "Accept invitation page works");
$ua->content_contains("The group is not active.", "Can't accept invitations to inactive groups");

$ua->get_ok("http://localhost/group/1/invite/decline", "Accept invitation page works");
$ua->content_contains("The group is not active.", "Can't accept invitations to inactive groups");


done_testing;
