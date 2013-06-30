use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;
use Test::MockObject;

our $schema = need_database 'pending_changes';

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

my $change_rs = $schema->resultset('ContactChange');

my $change5 = $change_rs->find({ 'id' => 5 });
my $change7 = $change_rs->find({ 'id' => 7 });

my $contact1 = $change5->contact;
my $contact2 = $change7->contact;

is $contact1->name, 'Tester01', 'name is Tester01';
is $contact2->name, 'Admin', 'name is Admin';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->post_ok('http://localhost/json/admin/approve_change/submit',
    {
        approve_changes => '5 7',
        change_item => 'cc',
        action_5 => 'approve',
        action_7 => 'approve'
    }
);

$contact1->discard_changes;
$contact2->discard_changes;

is $contact1->name, 'Tester001', 'Name has changed to Tester001';
is $contact2->name, 'Administrator', 'Name has changed to Administrator';

is $contact1->last_change->affected_change->id, 5, 'affected change is correct';
is $contact2->last_change->affected_change->id, 7, 'affected change is correct';

done_testing;
