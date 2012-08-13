use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $change_rs = $schema->resultset('CloakChange');

my $change1 = $change_rs->find({ 'id' => 1 });
my $change4 = $change_rs->find({ 'id' => 4 });

ok !$change1->approved, 'change has not been approved yet.';
ok !$change1->rejected, 'change has not been rejected yet.';

ok !$change4->approved, 'change has not been approved yet.';
ok !$change4->rejected, 'change has not been rejected yet.';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->get_ok("http://localhost/admin/approve_cloak", "Change approval page works");

$ua->submit_form(
    fields => {
        action_1 => 'approve',
        action_4 => 'reject'
    }
);

$change1->discard_changes;
$change4->discard_changes;

ok $change1->approved, 'change has been approved';
ok $change4->rejected, 'change has been rejected.';

done_testing;
