use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $change_rs = $schema->resultset('CloakChange');

my $change2 = $change_rs->find({ 'id' => 2 });
my $change3 = $change_rs->find({ 'id' => 3 });

ok !$change2->accepted, 'change has not been accepted yet.';
ok !$change2->rejected, 'change has not been rejected yet.';

ok !$change3->accepted, 'change has not been accepted yet.';
ok !$change3->rejected, 'change has not been rejected yet.';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get_ok("http://localhost/cloak", "Check cloak page works");

$ua->content_contains("example2/test01", "Cloak is there");
$ua->content_contains("example3/test01", "Cloak is there");

$ua->form_name('example2/test01');
$ua->click_button(
    number => 1
);

$ua->content_contains("Successfully approved the cloak", "Approval worked");

$change2->discard_changes;

ok $change2->accepted, "Approval worked.";

$ua->content_lacks("example2/test01", "Approved cloak is no longer there.");

$ua->form_name('example3/test01');
$ua->click_button(
    number => 2
);

$ua->content_contains("Successfully rejected the cloak", "Rejection worked.");

$change3->discard_changes;

ok $change3->rejected, "Rejection worked.";

$ua->content_lacks("example2/test01", "Approved cloak is no longer there.");
$ua->content_lacks("example3/test01", "Rejected cloak is no longer there.");

done_testing;
