use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;

need_database 'approved_group';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockGroup = new Test::MockModule('GMS::Domain::Group');
$mockGroup->mock ('new',
    sub {
        my (undef, undef, $group) = @_;
        $group;
    });

my $mockSession = new Test::MockModule ('GMS::Web::Model::Atheme');

$mockSession->mock ('session', sub {
    });

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get_ok("http://localhost/group/1/view", "View group page works");

$ua->get_ok("http://localhost/group/1/edit", "Edit page works");

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

$ua->content_contains ("Successfully submitted the change request", "Editing works");

$ua->get_ok("http://localhost/group/1/edit", "Edit page works");

$ua->content_contains ("already a change request", "A warning is shown if a previous change exists");

$ua->content_contains ("http://example.org", "New URL is shown");
$ua->content_contains ("new_address", "New address is shown");

my $schema = GMS::Schema->do_connect;

my $group = $schema->resultset('Group')->find({ group_name => 'group01' });
ok($group, "Check group exists");

is $group->url, 'http://example.com/', 'Requesting a change doesn\'t actually change something';
is $group->address, undef, 'Requesting a change doesn\'t actually change something';

$ua->get_ok("http://localhost/group/1/edit", "Edit page works");

$ua->submit_form(
    fields => {
        has_address => 'y',
        update_address => 'n',
        address_one => 'another_address',
        city => 'city',
        state => 'state',
        code => '001',
        country => 'country',
        phone => 1234567890
    }
);
$ua->get_ok("http://localhost/group/1/edit", "Edit page works");

$ua->content_contains ("new_address", "Address won't be updated if update address option is 'no'");

$ua->submit_form(
    fields => {
        has_address => 'n',
        update_address => 'n',
    }
);
$ua->get_ok("http://localhost/group/1/edit", "Edit page works");

$ua->content_contains ("new_address", "Address won't be updated if update address option is 'no'");

$ua->submit_form(
    fields => {
        has_address => 'n',
        update_address => 'y',
    }
);
$ua->get_ok("http://localhost/group/1/edit", "Edit page works");

$ua->content_lacks ("new_address", "We can request to remove a group's address");

$ua->submit_form(
    fields => {
        url => '! is an invalid url',
    }
);

$ua->content_contains ("Group URL contains invalid characters", "Invalid change errors are shown");

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

done_testing;
