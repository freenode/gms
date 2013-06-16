use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::More;
use Test::MockModule;
use Test::MockObject;

our $schema = need_database 'staff';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });

my $mockAtheme = new Test::MockObject;

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

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

$ua->get_ok("http://localhost/admin/group/1/view", "View group page works");

$ua->content_contains ("<h2>Group01</h2>", "View group page works");
$ua->content_contains ("<tr> <td>Type</td>              <td>informal</td> </tr>");
$ua->content_contains ("<tr> <td>URL</td>               <td>http://www.example.com/</td> </tr>");
$ua->content_contains ("<tr> <td>Status</td>            <td>active</td> </tr>");
$ua->content_contains ("<tr> <td>Verification URL</td>  <td>http://www.example.com//dhxtohuj.txt</td> </tr>");
$ua->content_contains ("<tr> <td>Verification token</td><td>yficqfvmxpra</td> </tr>");
$ua->content_contains ("<tr> <td>DNS pointing to freenode.net</td> <td>freenode-odwnvkm.example.com</td> </tr>");
$ua->content_contains ("Tester 1 (test01)", "Contacts are displayed");

$ua->get_ok("http://localhost/admin/group/38/view", "View group page works");

$ua->content_contains ("<h2>group122</h2>");
$ua->content_contains ("Historical/Inactive Contacts", "Inactive Contacts are displayed");
$ua->content_contains("Test 2 (test02)", "Inactive Contacts are displayed");

$ua->get_ok("http://localhost/admin/group/1/edit", "Edit group page works");

$ua->submit_form(
    fields => {
        url => '! is an invalid url',
    }
);

$ua->content_contains ("Group URL contains invalid characters", "Invalid change errors are shown");

$ua->get_ok("http://localhost/admin/group/1/edit", "Edit group page works");

$ua->submit_form(
    fields => {
        has_address => 'y',
        update_address => 'y',
        address_one => 'new_address',
        city => 'city',
        state => 'state',
        code => '001',
        country => 'country',
        phone => 'invalid'
    }
);

$ua->content_contains ("If the group has its own address, then a valid address must be specified.", "Invalid address errors are shown");
$ua->content_contains ("Telephone number contains non-digit characters", "Invalid address errors are shown");

$ua->get_ok("http://localhost/admin/group/1/edit", "Edit group page works");

$ua->submit_form(
    fields => {
        url => 'http://example.org',
        has_address => 'y',
        update_address => 'y',
        address_one => 'new_address',
        city => 'city',
        state => 'state',
        code => '001',
        country => 'country',
        phone => 1234567890
    }
);

$ua->content_contains ("Successfully edited the group's information.", "Editing works");

$ua->get_ok("http://localhost/admin/group/1/edit", "Edit page works");

$ua->content_contains ("http://example.org", "New URL is shown");
$ua->content_contains ("new_address", "New Address is shown");

my $group = $schema->resultset('Group')->find({ group_name => 'Group01' });
ok($group, "Check group exists");

is $group->url, 'http://example.org', 'Changes by admin take effect immediatelly';
is $group->address->address_one, 'new_address', 'Changes by admin take effect immediatelly';

$ua->submit_form(
    fields => {
        url => 'http://example.org',
        has_address => 'y',
        update_address => 'n',
        address_one => 'new_address_one'
    }
);

$group->discard_changes;
is $group->address->address_one, 'new_address', 'update_address => n will not update address';

$ua->get_ok("http://localhost/admin/group/1/edit", "Edit page works");

$ua->submit_form(
    fields => {
        url => 'http://example.org',
        has_address => 'n',
        update_address => 'n',
    }
);

$group->discard_changes;
is $group->address->address_one, 'new_address', 'update_address => n will not update address';

$ua->get_ok("http://localhost/admin/group/1/edit", "Edit page works");

$ua->submit_form(
    fields => {
        url => 'http://example.org',
        has_address => 'n',
        update_address => 'y',
    }
);

$group->discard_changes;
is $group->address, undef, 'Address can be removed';

my $user = $schema->resultset('Account')->search({accountname => 'test01'})->single;
ok $user;
ok $group->change ( $user, 'request', { url => 'http://example.net' });

$ua->get_ok("http://localhost/admin/group/1/edit", "Edit page works");

$ua->content_contains ( "Warning: There is already a change request pending for this group.", "Request is recognised");
$ua->content_contains ( "http://example.net", "Request is recognised");

done_testing;
