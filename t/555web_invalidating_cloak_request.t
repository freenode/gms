use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;
use Test::MockObject;
use RPC::Atheme::Error;
use GMS::Domain::Account;

our $schema = need_database 'new_db';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $user = $schema->resultset('Account')->find ({ 'accountname' => 'account0' });
my $admin = $schema->resultset('Account')->find({ 'accountname' => 'admin' });
my $group = $schema->resultset('Group')->find({ 'group_name' => 'group020' });

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

my $mockAtheme = new Test::MockObject;

$mockAtheme->mock('service', sub { 'GMSServ' });
$mockAtheme->mock('command', sub { } );

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        my $account = $schema->resultset('Account')->find ({ id => $uid });

        return GMS::Domain::Account->new( $uid, $account->accountname, $mockAtheme, $account );
    });


my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin", "Check we can log in");

my $req = $schema->resultset('CloakChange')->create({
        cloak        => 'group0/user0',
        group        => $group,
        changed_by   => $user,
        target       => $user,
        status       => 'accepted',
    });

$ua->get_ok(
    'http://localhost/json/admin/approve_cloak',
);

$ua->content_contains('group0/user0', 'Request is there.');

my $namespace = $schema->resultset('CloakNamespace')->find({
        namespace   => 'group0'
    });

$namespace->change(
        $admin,
        'workflow_change',
        {
            status      => 'deleted'
        }
    );

$ua->get_ok(
    'http://localhost/json/admin/approve_cloak',
);

$ua->content_lacks('group0/user0', 'Inactive request is not there');

done_testing;
