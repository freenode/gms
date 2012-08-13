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

$ua->get_ok("http://localhost/staff/search_users", "Check search users page works");

$ua->submit_form(
    fields => {
        accountname => 'test01'
    }
);

$ua->content_contains ("test01</a>", "User is found"); # make sure we're matching the url to the user,
                                                          # not the hidden inputs that keep the current search.

$ua->get_ok("http://localhost/staff/search_users", "Check search users page works");

$ua->submit_form(
    fields => {
        accountname => 'test%'
    }
);

$ua->content_contains ("test01</a>", "User is found");
$ua->content_contains ("test02</a>", "User is found");
$ua->content_contains ("test03</a>", "User is found");
$ua->content_contains ("test04</a>", "User is found");

$ua->get_ok("http://localhost/staff/search_users", "Check search users page works");

$ua->submit_form(
    fields => {
        fullname => 'test02'
    }
);

$ua->content_contains ("test02</a>", "User is found");

$ua->get_ok("http://localhost/staff/search_users", "Check search users page works");

$ua->submit_form(
    fields => {
        fullname => 'test0%'
    }
);

$ua->content_contains ("test02</a>", "User is found");
$ua->content_contains ("test04</a>", "User is found");

$ua->get_ok("http://localhost/staff/search_users", "Check search users page works");

$ua->submit_form(
    fields => {
        fullname => 'tester'
    }
);

$ua->content_contains("Unable to find any users that match your search criteria", "User not found");

done_testing;
