use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;
use Test::MockObject;
use GMS::Exception;

our $schema = need_database 'new_db';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockGroup = new Test::MockModule('GMS::Domain::Group');
$mockGroup->mock ('new',
    sub {
        my (undef, undef, $group) = @_;
        $group;
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

$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'account0',
        'cloak_namespace' => 'namespace0',
        'cloak' => 'test'
    }
);

$ua->content_contains("Successfully requested namespace0/test cloak for account0", "Requesting cloak wokrs");

$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'invalid',
        'cloak_namespace' => 'namespace0',
        'cloak' => 'invalid'
    }
);

$ua->content_contains("Could not find an account with that account name.", "Can't cloak user that does not exist");

$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'account0',
        'cloak_namespace' => 'namespace0',
        'cloak' => undef
    }
);

$ua->content_contains("The cloak cannot be empty", "Can't have empty cloak");

$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'account0',
        'cloak_namespace' => 'namespace0',
        'cloak' => '!!@#'
    }
);

$ua->content_contains("The cloak contains invalid characters", "Can't have invalid cloak");

$ua->get_ok("http://localhost/group/2/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'account0',
        'cloak_namespace' => 'namespace0',
        'cloak' => 'LoremipsumdolorsitametconsecteturadipiscingelitMaurisegetrutrumm'
    }
);

$ua->content_contains("The cloak is too long", "Can't have invalid cloak");

done_testing;
