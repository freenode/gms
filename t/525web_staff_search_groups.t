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

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        group_name => 'group01'
    }
);

$ua->content_contains ("group01</a>", "Group is found"); # make sure we're matching the url to the group,
                                                          # not the hidden inputs that keep the current search.

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        group_name => 'group%'
    }
);

$ua->content_contains ("group01</a>", "Group is found");
$ua->content_contains ("group02</a>", "Group is found");
$ua->content_contains ("group03</a>", "Group is found");
$ua->content_contains ("group04</a>", "Group is found");

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        gc_accname => 'test02'
    }
);

$ua->content_contains ("group01</a>", "Group is found");
$ua->content_contains ("group04</a>", "Group is found");

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        gc_accname => 'test0%'
    }
);

$ua->content_contains ("group01</a>", "Group is found");

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        group_type => 'informal'
    }
);

$ua->content_contains ("group01</a>", "Group is found");

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        group_type => 'corporation'
    }
);

$ua->content_contains ("group04</a>", "Group is found");

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        group_type => 'education'
    }
);

$ua->content_contains ("Unable to find any groups that match your search criteria.", "No group exists");

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        group_status => 'pending_staff'
    }
);

$ua->content_contains ("group02</a>", "Group is found");

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        group_status => 'pending_auto'
    }
);

$ua->content_contains ("group03</a>", "Group is found");

$ua->get_ok("http://localhost/staff/search_groups", "Check search groups page works");

$ua->submit_form(
    fields => {
        group_status => 'verified'
    }
);

$ua->content_contains ("Unable to find any groups that match your search criteria.", "No group exists");

done_testing;
