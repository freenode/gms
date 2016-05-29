use lib qw(t/lib);
use GMSTest::Common 'three_groups';
use GMSTest::Database;
use Test::More;
use Test::MockModule;

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});

my $mockDNS = Test::MockModule->new ('Net::DNS::Resolver');
$mockDNS->mock ('search', sub { });

my $db = need_database 'three_groups';

# We don't want this right now.

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});

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

my $admin = $db->resultset('Account')->find({ accountname => 'admin01' });
my $group = $db->resultset('Group')->find({ id => 3 });

$group->verify($admin, '');

$ua->get_ok ("http://localhost/group/3/verify", "Verification page works");
$ua->content_contains("The group has already been verified", "Can't verify verified groups.");


done_testing;
