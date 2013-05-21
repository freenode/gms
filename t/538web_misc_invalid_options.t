use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $change_rs = $schema->resultset('GroupContactChange');
my $gc_rs = $schema->resultset('GroupContact');

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->get_ok("http://localhost/admin/approve_change", "Change approval page works");

$ua->submit_form(
    fields => {
        change_item => 6
    }
);

$ua->content_contains("Invalid change item", "Providing an invalid change item errors");

$ua->submit_form(
    fields => {
        change_item => undef
    }
);

$ua->content_lacks("Invalid change item", "Providing no change item is ok");

$ua->get_ok("http://localhost/admin/approve_namespaces", "Namespace approval page works");

$ua->submit_form(
    fields => {
        approve_item => 3
    }
);

$ua->content_contains("Invalid option", "Providing an invalid namespace item errors");

$ua->submit_form(
    fields => {
        approve_item => undef
    }
);

$ua->content_lacks("Invalid option", "Providing no namespace item is ok");

$ua->get_ok("http://localhost/admin/search_changes", "Change search page works");

$ua->submit_form(
    fields => {
        change_item => 7
    }
);

$ua->content_contains("Invalid option", "Providing an invalid option errors");

$ua->submit_form(
    fields => {
        change_item => undef
    }
);

$ua->content_lacks("Invalid option", "Providing no option is ok");

done_testing;
