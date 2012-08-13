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

$ua->get_ok("http://localhost/group/1/edit", "Edit page works");

$ua->submit_form(
    fields => {
        url => 'http://example.org'
    }
);

$ua->content_contains ("Successfully submitted the change request", "Editing works");

$ua->get_ok("http://localhost/group/1/edit", "Edit page works");

$ua->content_contains ("already a change request", "A warning is shown if a previous change exists");

$ua->content_contains ("http://example.org", "New URL is shown");

my $schema = GMS::Schema->do_connect;

my $group = $schema->resultset('Group')->find({ group_name => 'group01' });
ok($group, "Check group exists");

is $group->url, 'http://example.com/', 'Requesting a change doesn\'t actually change something';

done_testing;
