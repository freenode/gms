use lib qw(t/lib);
use GMSTest::Common;
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

$ua->get_ok("http://localhost/staff/account/AAAAAAAAP/view", "View account page works");

$ua->content_contains("test01's contact information", "Account viewing page works");

$ua->content_contains ("<tr> <td>Account name:</td> <td>test01</td> </tr>", "Account viewing page works");
$ua->content_contains ("<tr> <td>Real name:</td> <td>test01</td> </tr>", "Account viewing page works");
$ua->content_contains ("<tr> <td>E-mail Address:</td> <td>test01\@example.com</td> </tr>", "Account viewing page works");

$ua->content_contains("<tr> <td>Address 1:</td> <td>Address</td> </tr>", "Account viewing works");
$ua->content_contains("<tr> <td>Address 2:</td> <td></td> </tr>", "Account viewing works");
$ua->content_contains("<tr> <td>City:</td> <td>City</td> </tr>", "Account viewing works");
$ua->content_contains("<tr> <td>State:</td> <td>State</td> </tr>", "Account viewing works");
$ua->content_contains("<tr> <td>Postal Code:</td> <td>92482</td> </tr>", "Account viewing works");
$ua->content_contains("<tr> <td>Country:</td> <td>Country</td> </tr>", "Account viewing works");
$ua->content_contains("<tr> <td>Telephone:</td> <td>0123456789</td> </tr>", "Account viewing works");
$ua->content_contains("<tr> <td>Telephone (Alternative):</td><td></td> </tr>", "Account viewing works");

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/edit", "Check contact info editing form");

$ua->submit_form(fields => {
        user_name => 'Second Contact Test',
        user_email => 'test03@example.com',
    });

$ua->content_contains("Successfully edited the user's contact information", "Check editing contact info");

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/edit", "Check contact info editing form");

$ua->content_contains("Second Contact Test", "The input fields have the new information for editing");
$ua->content_contains('test03@example.com', "The input fields have the new information for editing");

$ua->get_ok("http://localhost/staff/account/AAAAAAAAP/view", "View account page works");

$ua->content_contains("Second Contact Test", "Info has changed");
$ua->content_contains('test03@example.com', "Info has changed");

my $schema = GMS::Schema->do_connect;

my $account = $schema->resultset('Account')->find({ 'accountname' => 'test01' });
ok $account;
isa_ok $account, 'GMS::Schema::Result::Account';

is $account->contact->name, 'Second Contact Test', 'Admin changes are applied';
is $account->contact->email, 'test03@example.com', 'Admin changes are applied';

ok $account->contact->change ( $account, 'request', { 'name' => 'Another Test' });

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/edit", "Check contact info editing form");

$ua->content_contains ("already a change request pending", "Pending request is recognised");
$ua->content_contains ("Another Test", "Pending change is recognised");

$ua->submit_form(fields => {
        update_address => 'y',
        phone_one => 9876543210
    });

$account->contact->discard_changes;

is $account->contact->address->phone, 9876543210, 'Updating contact info works';

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/edit", "Check contact info editing form");

$ua->submit_form(fields => {
        update_address => 'y',
        phone_one => 'invalid'
    });

$ua->content_contains('Telephone number contains non-digit characters', 'Errors are shown');

done_testing;
