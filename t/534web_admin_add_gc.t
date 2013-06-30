use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;
use Test::MockObject;

our $schema = need_database 'approved_group';

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

$ua->get_ok("http://localhost/admin/group/1/add_gc", "GC addition page works");

$ua->submit_form (
    fields => {
        contact => 'test03'
    }
);

$ua->content_contains("Successfully added the group contact", "Adding a GC works");

$ua->get_ok("http://localhost/admin/group/1/add_gc", "GC addition page works");

$ua->submit_form (
    fields => {
        contact => 'test03'
    }
);

$ua->content_contains("This person has already been added.", "Adding a GC works");

my $schema = GMS::Schema->do_connect;

my $group = $schema->resultset('Group')->find({ group_name => 'group01' });
ok($group, "Check group exists");

is $group->group_contacts->count, 3, "Group has 3 contacts";
is $group->active_group_contacts->count, 3, "Group has 3 active contacts";

$ua->get_ok("http://localhost/admin/group/1/add_gc", "GC addition page works");

$ua->submit_form (
    fields => {
        contact => 'admin01'
    }
);

$ua->content_contains("This user doesn't exist or has no contact information defined", "Adding a user with no contact info fails");

$ua->get_ok("http://localhost/admin/group/1/add_gc", "GC addition page works");

$ua->submit_form (
    fields => {
        contact => 'doesnt_exist'
    }
);

$ua->content_contains("This user doesn't exist or has no contact information defined", "Adding a user that doesn't exist fails");

done_testing;
