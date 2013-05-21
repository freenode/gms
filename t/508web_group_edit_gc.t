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
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get_ok("http://localhost/group/1/edit_gc", "Edit group contacts page works");

$ua->content_contains("test01", "group contact is in the page");

diag $ua->content;

$ua->submit_form(
    fields => {
        action_1 => 'change',
        group_contacts => '1',
        status_1 => 'retired',
        primary_1 => 0,
    }
);

ok $ua->content_contains ("Successfully requested the GroupContactChanges", "Submitting changes works");

$ua->get_ok("http://localhost/group/1/edit_gc", "Edit group contacts page works");

ok $ua->content_contains ("At least one of the group's contacts has a change request pending", "Pending change is recognised.");

ok $ua->content_contains ('name="primary_1" value="1"  />', "Primary checkbox isn't checked.");

ok $ua->content_contains ('"retired"  selected', 'retired checkbox is selected');

$ua->submit_form(
    fields => {
        action_2 => 'change',
        primary_2 => 1,
    }
);

ok $ua->content_contains ("Successfully requested the GroupContactChanges", "Submitting changes works");

$ua->get_ok("http://localhost/group/1/edit_gc", "Edit group contacts page works");

ok $ua->content_contains ('name="primary_2" value="1"  checked  />', "Primary checkbox is checked.");

done_testing;
