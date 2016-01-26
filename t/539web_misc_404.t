use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::More;
use Test::MockModule;
use Test::MockObject;

our $schema = need_database 'staff';

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

my $resp = $ua->get("http://localhost/admin/999/view");
is $resp->code, 404, 'Trying to view a group that does not exist is 404';

$resp = $ua->get("http://localhost/admin/address/999/view");
is $resp->code, 404, 'Trying to view an address that does not exist is 404';

$resp = $ua->get("http://localhost/admin/account/999/view");
is $resp->code, 404, 'Trying to view an account that does not exist is 404';

$resp = $ua->get("http://localhost/admin/account/999/edit");
is $resp->code, 404, 'Trying to view an account that does not exist is 404';

$ua->get_ok ("http://localhost/logout");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test02',
        password => 'tester02'
    }
);

$ua->get("http://localhost/group/999/view");
$ua->content_contains("That group doesn't exist or you can't access it", "Can't view nonexistant group");

$ua->get("http://localhost/group/2/view");
$ua->content_contains("That group doesn't exist or you can't access it", "Trying to view a group you are not a member of errors");

$ua->get_ok ("http://localhost/logout");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'staff',
        password => 'staffer01'
    }
);

#$request = $ua->get("http://localhost/admin/9999/view");
#is $request->code, 404, "Nonexistant group is 404";

done_testing;
