use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::More;
use Test::MockModule;
use Test::MockObject;

our $schema = need_database 'new_db';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });

my $mockAtheme = new Test::MockObject;
$mockAtheme->mock('notice_staff_chan', sub {});

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });


my $change_rs = $schema->resultset('CloakChange');

my $change6 = $change_rs->find({ 'id' => 6 });
my $change12 = $change_rs->find({ 'id' => 12 });

ok $change6->active_change->status->is_offered, 'status is offered';
ok $change12->active_change->status->is_offered, 'status is offered';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'account5',
        password => 'tester05'
    }
);

$ua->content_contains("You are now logged in as account5", "Check we can log in");

$ua->get_ok("http://localhost/cloak", "Check cloak page works");

$ua->content_contains("group5/user5", "Cloak is there");

$ua->post ('http://localhost/cloak/6/approve');
$ua->content_contains ('Invalid action', 'invalid action errors');

$ua->form_name('group5/user5');
$ua->click_button(
    number => 1
);

$ua->content_contains("Successfully approved the cloak", "Approval worked");

$change6->discard_changes;

ok $change6->active_change->status->is_accepted, "Approval worked.";

$ua->content_lacks("group5/user5", "Approved cloak is no longer there.");

$ua->get("http://localhost/logout");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'account11',
        password => 'tester11'
    }
);

$ua->content_contains("You are now logged in as account11", "Check we can log in");

$ua->get_ok("http://localhost/cloak", "Check cloak page works");

$ua->content_contains("group11/user11", "Cloak is there");

$ua->form_name('group11/test11');
$ua->click_button(
    number => 2
);

$ua->content_contains("Successfully rejected", "Rejecting works");

$ua->get ("http://localhost/cloak/999/approve");
$ua->content_contains ("That cloak doesn't exist or hasn't been assigned to you.", "Can't approve cloak change that does not exist");

$ua->get ("http://localhost/cloak/4/approve");
$ua->content_contains ("That cloak doesn't exist or hasn't been assigned to you.", "Can't approve cloak change that belongs to someone else");

done_testing;
