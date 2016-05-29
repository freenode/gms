use lib qw(t/lib);
use GMSTest::Common 'pending_changes';
use GMSTest::Database;
use Test::More;
use Test::MockObject;
use Test::MockModule;


my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});

use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);

our ($file, $content);

need_database 'pending_changes';

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
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

my $schema = GMS::Schema->do_connect;

my $group = $schema->resultset('Group')->find({ group_name => 'group06' });
ok($group, "Check group exists");

$file = $group->verify_url;
$content = $group->verify_token;

{ # for the tiny httpd started to test web verification

    sub handle_request {
        my ($self, $cgi) = @_;

        my $path = $cgi->path_info;

        if ($file =~ /$path/) {
            print $content . "\n";
        }

        exit;
    }
}

__PACKAGE__->new(1337)->background;

$ua->get_ok ("http://localhost/group/6/verify", "Verification page works");
$ua->submit_form;

$ua->content_contains ("successfully verified", "Web verification worked");

$group = $schema->resultset('Group')->find({ id => 7 });

my $mockRecord = Test::MockObject->new;
$mockRecord->mock ('type' => sub { 'TXT' });
$mockRecord->mock ('char_str_list' => sub { $group->verify_dns });

my $mockResponse = Test::MockObject->new;
$mockResponse->mock ('answer' => sub { $mockRecord });

my $mockDNS = Test::MockModule->new ('Net::DNS::Resolver');
my $search;
$mockDNS->mock ('search', sub { $search = $_[1]; $mockResponse });

$ua->get_ok ("http://localhost/group/7/verify", "Verification page works");
$ua->submit_form;

like $search, qr/freenode-[a-z]+\.example\.co\.uk/, 'Querying the correct url.';

$ua->content_contains ("successfully verified", "Web verification worked");

done_testing;
