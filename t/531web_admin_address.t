use lib qw(t/lib);
use GMSTest::Common 'approved_group';
use GMSTest::Database;
use Test::More;

need_database 'approved_group';

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

$ua->get_ok("http://localhost/admin/address/1/view", "View address page works");

$ua->content_contains("<tr> <td>Address 1:</td> <td>Address</td> </tr>", "Address viewing works");
$ua->content_contains("<tr> <td>Address 2:</td> <td></td> </tr>", "Address viewing works");
$ua->content_contains("<tr> <td>City:</td> <td>City</td> </tr>", "Address viewing works");
$ua->content_contains("<tr> <td>State:</td> <td>State</td> </tr>", "Address viewing works");
$ua->content_contains("<tr> <td>Postal Code:</td> <td>92482</td> </tr>", "Address viewing works");
$ua->content_contains("<tr> <td>Country:</td> <td>Country</td> </tr>", "Address viewing works");
$ua->content_contains("<tr> <td>Telephone:</td> <td>0123456789</td> </tr>", "Address viewing works");
$ua->content_contains("<tr> <td>Telephone (alternate):</td> <td> </td></tr>", "Address viewing works");

done_testing;
