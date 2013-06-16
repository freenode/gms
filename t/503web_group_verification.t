use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;

need_database 'three_groups';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockGroup = new Test::MockModule('GMS::Domain::Group');
$mockGroup->mock ('new',
    sub {
        my (undef, undef, $group) = @_;
        $group;
    });

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test03',
        password => 'tester03'
    }
);

$ua->content_contains("You are now logged in as test03", "Check we can log in");

$ua->get_ok ("http://localhost/group/3/verify", "Verification page works");

$ua->submit_form;

$ua->content_contains("Unable to complete", "Empty form gets error");

$ua->submit_form(
    fields => {
        freetext => 'freetext'
    }
);

$ua->content_contains("Please wait for staff to verify", "Submitting verification form works");

done_testing;
