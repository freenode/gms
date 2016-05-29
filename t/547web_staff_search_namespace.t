use lib qw(t/lib);
use GMSTest::Common 'staff';
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
        username => 'staff',
        password => 'staffer01'
    }
);

$ua->content_contains("You are now logged in as staff", "Check we can log in");

$ua->get_ok("http://localhost/admin", "Admin page works");

$ua->get_ok("http://localhost/admin/search_namespaces", "Search namespaces page works");

$ua->submit_form(
    fields => {
        namespace => 'test120',
        search_item => 1,
    }
);

$ua->content_contains ('test120', 'Namespace exists');

$ua->get_ok("http://localhost/admin/search_namespaces", "Search namespaces page works");

$ua->submit_form(
    fields => {
        namespace => 'test120',
        search_item => 2,
    }
);

$ua->content_contains ('test120', 'Searching cloak namespaces works');

$ua->get_ok("http://localhost/admin/search_namespaces", "Search namespaces page works");

$ua->submit_form(
    fields => {
        namespace => 'invalid',
        search_item => 1,
    }
);

$ua->content_contains ("Unable to find any namespaces that match your search criteria. Please try again", "Error is shown if there is no match");

$ua->get_ok("http://localhost/admin/search_namespaces", "Search namespaces page works");

$ua->submit_form(
    fields => {
        namespace => '%',
        search_item => 1,
    }
);

$ua->content_contains("test0", "Searching works");

$ua->content_contains("Next page", "We can go to next page");
$ua->content_lacks("Previous page", "We can't go to previous page");
$ua->content_like(qr/last_page.*3/, "There are 3 pages");
$ua->content_like(qr/current_page.*1/, "We're at first page");

$ua->submit_form(
    fields => {
        'next' => 'Invalid option'
    }
);

$ua->content_like(qr/current_page.*1/, "Invalid paging request is ignored");

$ua->click_button(
    value => 'Next page'
);

$ua->content_contains("test101", "paging works");

$ua->content_contains("Next page", "We can go to next page");
$ua->content_contains("Previous page", "We can go to previous page");
$ua->content_like(qr/current_page.*2/, "We're at 2nd page");

$ua->click_button(
    value => 'Previous page'
);

$ua->content_contains("test0", "Paging works");
$ua->content_like(qr/current_page.*1/, "We're at first page");

$ua->click_button(
    value => 'Last page'
);

$ua->content_contains("test121", "Paging works");

$ua->content_lacks("Next page", "We can't go to next page");
$ua->content_contains("Previous page", "We can go to previous page");
$ua->content_like(qr/current_page.*3/, "We're at third page");

$ua->click_button(
    value => 'First page'
);

$ua->content_contains("test0", "Paging works");
$ua->content_like(qr/current_page.*1/, "We're at first page");

$ua->select ('page', 2 );
$ua->click_button(
    value => 'Go'
);

$ua->content_contains("test101", "paging works");
$ua->content_like(qr/current_page.*2/, "We're at 2nd page");

$ua->get("http://localhost/admin/search_namespaces");

$ua->submit_form(
    fields => {
        namespace => 'est',
        search_item => 1,
    }
);

$ua->content_contains('test106', 'Wildcard match is used');
$ua->content_contains('test107', 'Wildcard match is used');

done_testing;
