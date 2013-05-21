use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'staff';

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

my $response = $ua->get("http://localhost/staff");

is $response->code, 200, "Admin can access staff page.";

$ua->get_ok ("http://localhost/logout");

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'staff',
        password => 'staffer01'
    }
);

$ua->content_contains("You are now logged in as staff", "Check we can log in");

my $response = $ua->get("http://localhost/staff");

is $response->code, 200, "Staff can access staff page.";

$ua->get_ok ("http://localhost/logout");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

my $response = $ua->get("http://localhost/staff");

is $response->code, 403, "User can't access staff page.";

done_testing;
