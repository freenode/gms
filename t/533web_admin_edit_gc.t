use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
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

$ua->get_ok("http://localhost/admin/1/edit_gc", "Edit group contacts page works");

$ua->submit_form(
    fields => {
        action_1 => 'change',
        status_1 => 'retired',
        primary_1 => 0,
    }
);

ok $ua->content_contains ("Successfully edited the Group Contacts' information.", "Submitting changes works");

$ua->get_ok("http://localhost/admin/1/edit_gc", "Edit group contacts page works");

ok $ua->content_contains ('name="primary_1" value="1"  />', "Primary checkbox isn't checked.");

ok $ua->content_contains ('"retired"  selected', 'retired checkbox is selected');

my $schema = GMS::Schema->do_connect;
my $gc = $schema->resultset('GroupContact')->find_by_id ('1_1');
ok $gc;

is $gc->status->is_retired, 1, 'Admin change is applied';
is $gc->is_primary, 0, 'Admin change is applied';

$ua->submit_form(
    fields => {
        action_6 => 'change',
        primary_6 => 1,
    }
);

ok $ua->content_contains ("Successfully edited the Group Contacts' information.", "Submitting changes works");

$ua->get_ok("http://localhost/admin/1/edit_gc", "Edit group contacts page works");

ok $ua->content_contains ('name="primary_6" value="1"  checked  />', "Primary checkbox is checked.");

$gc = $schema->resultset('GroupContact')->find_by_id ('6_1');
ok $gc;

is $gc->is_primary, 1, 'Admin change is applied';

done_testing;
