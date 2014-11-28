use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::More;
use Test::MockObject;
use Test::MockModule;

# We don't want this right now.

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});


our $schema = need_database 'staff';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockGroup = new Test::MockModule('GMS::Domain::Group');
$mockGroup->mock ('new',
    sub {
        my (undef, undef, $group) = @_;
        $group;
    });

my $mockSession = new Test::MockModule ('GMS::Web::Model::Atheme');

$mockSession->mock ('session', sub {
    });

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });

my $mockAtheme = new Test::MockObject;

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'staff',
        password => 'staffer01'
    }
);

$ua->content_contains("You are now logged in as staff", "Check we can log in");

$ua->get_ok("http://localhost/staff", "Staff page works");

$ua->get_ok("http://localhost/staff/group/38/view");

$ua->text_contains ("group122", "View group page works");
$ua->text_like (qr#Type.*informal#);
$ua->text_like (qr#URL.*http://group122.example#);
$ua->text_like (qr#Status.*pending_web#);
$ua->text_like (qr#Verification URL.*http://group122.example/fgkyobfk.txt#);
$ua->text_like (qr#Verification token.*eubatkisggkd#);
$ua->text_like (qr#DNS pointing to freenode.net.*freenode-yfaynqp.group122.example#);

$ua->content_lacks ("Historical/Inactive Contacts", "Staff don't see historical/inactive contacts");

done_testing;
