use lib qw(t/lib);
use GMSTest::Common 'new_db';
use GMSTest::Database;
use Test::More;
use Test::MockModule;
use Test::MockObject;

our $schema = need_database 'new_db';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });
$mockAccounts->mock ('find_by_name', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ accountname => $uid });
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
        username => 'admin',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin", "Check we can log in");

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 1,
        gc_accname => 'account1',
        gc_groupname => 'group021'
    }
);

$ua->content_contains ('request', 'Change is there');
$ua->content_contains ('approve', 'Change is there');
$ua->content_contains ('active', 'Change is there');

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 2,
        group_name => 'group0'
    }
);

$ua->content_contains ('create', 'Change is there');
$ua->content_contains ('pending_web', 'Change is there');
$ua->content_contains ('workflow_change', 'Change is there');
$ua->content_contains ('pending_web', 'Change is there');
$ua->content_contains ('pending_auto', 'Change is there');
$ua->content_contains ('admin', 'Change is there');
$ua->content_contains ('active', 'Change is there');

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 4,
        groupname => 'group031',
        namespace => 'namespace1'
    }
);

$ua->content_contains ('request', 'Change is there');
$ua->content_contains ('approve', 'Change is there');
$ua->content_contains ('admin', 'Change is there');
$ua->content_contains ('active', 'Change is there');
$ua->content_contains ('Changed By: admin', 'Change is there');
$ua->content_contains ('Affected Change: 6', 'Change is there');

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 5,
        cloak_groupname => 'group031',
        cloak_namespace => 'namespace1'
    }
);

$ua->content_contains ('request', 'Change is there');
$ua->content_contains ('approve', 'Change is there');
$ua->content_contains ('admin', 'Change is there');
$ua->content_contains ('active', 'Change is there');
$ua->content_contains ('Changed By: admin', 'Change is there');
$ua->content_contains ('Affected Change: 6', 'Change is there');

$ua->submit_form (
    fields => {
        change_item => 6,
        cloak_accountname => 'account6'
    }
);

$ua->content_contains ('group6/user6', 'Change is there 8');
$ua->content_contains ('applied', 'Change is there');

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 7,
        target => 'account0'
    }
);

$ua->content_contains ('account0', 'change is there');
$ua->content_contains ('#group0', 'change is there');
$ua->content_contains ('transfer', 'change is there');
$ua->content_contains ('applied', 'change is there');
$ua->content_contains ('admin', 'change is there');

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 1,
        gc_accname => 'account1',
        gc_groupname => 'oup'
    }
);

$ua->content_contains('group021', 'wildcard match is used.');

done_testing;
