use lib qw(t/lib);
use GMSTest::Common 'new_db';
use GMSTest::Database;
use Test::More;
use Test::MockObject;
use GMS::Exception;

use Test::MockModule;

# We don't want this right now.

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});


our $schema = need_database 'new_db';

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

        my $account = $schema->resultset('Account')->find ({ id => $uid });

        if (!$account) {
            die GMS::Exception->new ("Could not find an account with that UID.");
        }

        $account;
    });
$mockAccounts->mock ('find_by_name', sub {
        my ( $self, $uid ) = @_;

        my $account = $schema->resultset('Account')->find ({ accountname => $uid });

        if (!$account) {
            die GMS::Exception->new ("Could not find an account with that account name.");
        }

        $account;
    });

my $mockAtheme = new Test::MockObject;
$mockAtheme->mock ('service', sub { 'GMSServ' });

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'account0',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as account0", "Check we can log in");

$ua->get_ok("http://localhost/group/2/cloak", "cloak page works");

$ua->submit_form(
    fields => {
        'num_cloaks' => 1,
        'accountname_0' => 'account0',
        'cloak_namespace_0' => 'group0',
        'cloak_0' => 'test'
    }
);

$ua->content_contains("Successfully requested 1 cloak(s)", "Requesting cloak wokrs");

$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        'num_cloaks' => 1,
        'accountname_0' => 'invalid',
        'cloak_namespace_0' => 'group0',
        'cloak_0' => 'invalid'
    }
);

$ua->content_contains("Could not find an account with that account name", "Can't cloak user that does not exist");

$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");


$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        'num_cloaks' => 1,
        'accountname_0' => 'account0',
        'cloak_namespace_0' => 'group0',
        'cloak_0' => '!!@#'
    }
);

$ua->content_contains("The role/user contains invalid characters", "Can't have invalid cloak");

$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        'num_cloaks' => 1,
        'accountname_0' => 'account0',
        'cloak_namespace_0' => 'group0',
        'cloak_0' => 'LoremipsumdolorsitametconsecteturadipiscingelitMaurisegetrutrummf'
    }
);

$ua->content_contains("The cloak is too long", "Can't have invalid cloak");

$ua->get_ok("http://localhost/group/2/cloak", "cloak page works");

$ua->submit_form(
    fields => {
        'num_cloaks' => 1,
        'accountname_0' => 'account0',
        'cloak_namespace_0' => 'invalid',
        'cloak_0' => 'test'
    }
);

$ua->content_contains("The namespace invalid does not belong in your Group's namespaces.", "Can't have a cloak in a namespace you don't own");

$ua->get_ok("http://localhost/group/2/cloak", "cloak page works");

$ua->submit_form(
    fields => {
        'num_cloaks' => 1,
        'accountname_0' => 'account0',
        'cloak_namespace_0' => 'group0',
        'cloak_0' => '42'
    }
);

$ua->content_contains("The cloak provided looks like a CIDR mask", "Can't have invalid cloak");

$ua->get_ok("http://localhost/group/2/cloak", "cloak page works");

$ua->submit_form(
    fields => {
        'num_cloaks' => 1,
        'accountname_0' => 'account0',
        'cloak_namespace_0' => 'group0',
        'cloak_0' => '42/1337'
    }
);

$ua->content_contains("The cloak provided looks like a CIDR mask", "Can't have invalid cloak");

$ua->get_ok("http://localhost/group/2/cloak", "cloak page works");

$ua->submit_form(
    fields => {
        'num_cloaks' => 1,
        'accountname_0' => 'account0',
        'cloak_namespace_0' => 'group0',
        'cloak_0' => 'foo/bar/'
    }
);

$ua->content_contains("The cloak cannot end with a slash", "Can't have invalid cloak");

$ua->get_ok("http://localhost/group/2/cloak", "cloak page works");

$ua->submit_form(
    fields => {
        'num_cloaks' => 1,
        'accountname_0' => 'account0',
        'cloak_namespace_0' => 'group0',
        'cloak_0' => '42/this-should-work'
    }
);

$ua->content_contains("Successfully requested 1 cloak(s)", "Requesting cloak works");

my $group = $schema->resultset('Group')->find({ group_name => 'group020' });
my $admin = $schema->resultset('Account')->find({ accountname => 'admin' });

$group->change( $admin, 'workflow_change', { status => 'pending_staff' });

$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");
$ua->content_contains("The group is not active", "Can't set cloaks on inactive group");


done_testing;
