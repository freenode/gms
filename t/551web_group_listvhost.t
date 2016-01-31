use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::More;
use Test::MockObject;
use Test::MockModule;

# We don't want this right now.

my $mock = Test::MockModule->new('GMS::Atheme::Client');
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
        username => 'account0',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as account0", "Check we can log in");

$mockAtheme->mock ( 'command' => sub {
    return "- admin group0/cloak\n" .
    "- user group0/anothercloak\n" .
    "2 Results total";
});
$mockModel->mock ('session' => sub { $mockAtheme });

$ua->get_ok("http://localhost/group/2/listvhost", "list cloak page works");

$ua->content_contains ("admin - group0/cloak", "Cloak is visible - no need for a form");
$ua->content_contains ("user - group0/anothercloak", "Cloak is visible - no need for a form");

my $group = $schema->resultset('Group')->find({ id => 2 });
$group->add_to_cloak_namespaces({ namespace => 'group01', 'group_id' => 2, 'status' => 'active', 'account' => 'AAAAAAAAH'});

$ua->get_ok("http://localhost/group/2/listvhost", "list cloak page works");

$ua->content_lacks ("admin - group0/cloak", "need to choose namespace if more than one");
$ua->content_lacks ("user - group0/anothercloak", "need to choose namespace if more than one");

my $cloak = $schema->resultset("CloakChange")->create({
        cloak => 'group0/user',
        group => $group,
        target => 'AAAAAAAAH',
        requestor => 'AAAAAAAAH',
        changed_by => 'AAAAAAAAH'
    });

$ua->submit_form (
    fields => {
        'namespace' => 'group0'
    }
);

my $group = $schema->resultset('Group')->find({ id => 2 });

$ua->content_contains ("admin - group0/cloak", "Cloak is visible after form");
$ua->content_contains ("user - group0/anothercloak", "Cloak is visible after form");
$ua->content_contains ("group0/user (Waiting user approval)", "pending cloaks are shown");

my $admin = $schema->resultset('Account')->find({ id => 'AAAAAAAAH' });
$cloak->accept($admin);

$ua->get_ok("http://localhost/group/2/listvhost", "list cloak page works");
$ua->submit_form (
    fields => {
        'namespace' => 'group0'
    }
);

$ua->content_contains ("group0/user (Waiting staff approval)", "pending cloaks are shown");


$ua->get_ok("http://localhost/group/2/listvhost", "list cloak page works");
$ua->submit_form (
    fields => {
        'namespace' => 'invalid'
    }
);

$ua->content_contains ("The namespace invalid does not belong", "errors are shown");

$ua->get_ok("http://localhost/group/2/listvhost", "list cloak page works");

$mockAtheme->mock ( 'command' => sub {
    die RPC::Atheme::Error->new (1, 'Test error');
});
$mockModel->mock ('session' => sub { $mockAtheme });

$ua->submit_form (
    fields => {
        'namespace' => 'group0'
    }
);

$ua->content_contains ("Test error", "Errors are shown");


my $group = $schema->resultset('Group')->find({ group_name => 'group020' });
my $admin = $schema->resultset('Account')->find({ accountname => 'admin' });

$group->change( $admin, 'workflow_change', { status => 'pending_staff' });

$ua->get_ok("http://localhost/group/2/listvhost", "List Cloak page works");
$ua->content_contains("The group is not active", "Can't list cloaks on inactive group");


done_testing;
