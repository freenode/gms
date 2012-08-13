use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->get_ok("http://localhost/staff/search_namespaces", "Check search namespaces page works");

$ua->submit_form(
    fields => {
        search_item => 1,
        namespace => 'example'
    }
);

$ua->content_contains ("group01</a>", "Group with namespace is found"); # make sure we're matching the url to the group,
                                                          # not the hidden inputs that keep the current search.

$ua->get_ok("http://localhost/staff/search_namespaces", "Check search namespaces page works");

$ua->submit_form(
    fields => {
        search_item => 1,
        namespace => 'example%'
    }
);

$ua->content_contains ("group01</a>", "Group with namespace is found");
$ua->content_contains ("group02</a>", "Group with namespace is found");
$ua->content_contains ("group03</a>", "Group with namespace is found");

$ua->get_ok("http://localhost/staff/search_namespaces", "Check search namespaces page works");

$ua->submit_form(
    fields => {
        search_item => 2,
        namespace => 'example'
    }
);

$ua->content_contains ("group01</a>", "Group with namespace is found");

$ua->get_ok("http://localhost/staff/search_namespaces", "Check search namespaces page works");

$ua->submit_form(
    fields => {
        search_item => 2,
        namespace  => 'example%'
    }
);

$ua->content_contains ("group01</a>", "Group with namespace is found");
$ua->content_contains ("group04</a>", "Group with namespace is found");

done_testing;
