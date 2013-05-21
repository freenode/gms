use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

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

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 1,
        gc_accname => 'test02',
        gc_groupname => 'group01'
    }
);

$ua->content_contains ('workflow_change', 'Change is there');
$ua->content_contains ('pending_staff', 'Change is there');
$ua->content_contains ('approve', 'Change is there');
$ua->content_contains ('active', 'Change is there');
$ua->content_contains ('Test freetext', 'Change is there');

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 2,
        group_name => 'group01'
    }
);

$ua->content_contains ('create', 'Change is there');
$ua->content_contains ('pending_web', 'Change is there');
$ua->content_contains ('workflow_change', 'Change is there');
$ua->content_contains ('pending_staff', 'Change is there');
$ua->content_contains ('request', 'Change is there');
$ua->content_contains ('active', 'Change is there');

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 3,
        accname => 'test01'
    }
);

$ua->content_contains ('request', 'Change is there');
$ua->content_contains ('Tester01', 'Change is there');

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 4,
        groupname => 'group04',
        namespace => 'new_namespace_3'
    }
);

$ua->content_contains ('create', 'Change is there');
$ua->content_contains ('pending_staff', 'Change is there');
$ua->content_contains ('admin', 'Change is there');
$ua->content_contains ('active', 'Change is there');
$ua->content_contains ('Changed By: admin01', 'Change is there');
$ua->content_contains ('request', 'Change is there');
$ua->content_contains ('deleted', 'Change is there');
$ua->content_contains ('approve', 'Change is there');
$ua->content_contains ('Affected Change: 12', 'Change is there');

$ua->get_ok("http://localhost/admin/search_changes", "Search changes page works");

$ua->submit_form (
    fields => {
        change_item => 5,
        cloak_groupname => 'group04',
        cloak_namespace => 'new_namespace_3'
    }
);

$ua->content_contains ('create', 'Change is there');
$ua->content_contains ('pending_staff', 'Change is there');
$ua->content_contains ('admin', 'Change is there');
$ua->content_contains ('active', 'Change is there');
$ua->content_contains ('Changed By: admin01', 'Change is there');
$ua->content_contains ('request', 'Change is there');
$ua->content_contains ('deleted', 'Change is there');
$ua->content_contains ('approve', 'Change is there');
$ua->content_contains ('Affected Change: 9', 'Change is there');

$ua->submit_form (
    fields => {
        change_item => 6,
        cloak_accountname => 'test02'
    }
);

$ua->content_contains ('example/test02', 'Change is there');
$ua->content_contains ('Time offered: 2012', 'Change is there');
$ua->content_contains ('Time accepted: 2012', 'Change is there');
$ua->content_contains ('Time approved: 2012', 'Change is there');
$ua->content_contains ('Time rejected:  not rejected', 'Change is there');
$ua->content_contains ('Changed By: test02', 'Change is there');

$ua->content_contains ('example/test02/another', 'Change is there');
$ua->content_contains ('Time offered: 2012', 'Change is there');
$ua->content_contains ('Time accepted: 2012', 'Change is there');
$ua->content_contains ('Time approved:  not approved', 'Change is there');
$ua->content_contains ('Time rejected:  not rejected', 'Change is there');

done_testing;
