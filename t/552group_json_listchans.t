use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockObject;
use Test::MockModule;
use RPC::Atheme::Error;
use JSON::XS;

my $mock = Test::MockModule->new('GMS::Atheme::Client');

our $schema = need_database 'approved_group';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockAtheme = new Test::MockObject;

$mockAtheme->mock ( 'command', sub {
    shift @_;

    my ($service, $command, $param1, $param2) = ( @_ );

    if ($service eq 'ChanServ' && $command eq 'list' && $param1 eq 'pattern') {
        if ($param2 eq '#example') {
            return "\n- #example (test)\n \n";
        } elsif ($param2 eq '#example-*') {
            return "\n- #example-1 (test)\n- #example-2 (test)\n \n";
        }
    }

});

$mockAtheme->mock ( 'service', sub { 'GMSServ' } );

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

$ua->get_ok("http://localhost/json/group/1/listchans", "Listing channels page");

$ua->content_contains('Login to GMS', 'need to log in');

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->get_ok("http://localhost/json/group/1/listchans", "Listing channels page");


my $json = decode_json($ua->content);

is_deeply $json->{json_channels}, [
    '#example',
    '#example-1',
    '#example-2'
];

$ua->get_ok("http://localhost/json/group/1/listchans", "Listing channels page");

my $json = decode_json($ua->content);

$ua->get("http://localhost/json/group/2/listchans", "Listing channels page");

is $ua->response->code, 404, "Can't access nonexistant group";

my $json = decode_json($ua->content);
ok !$json->{json_success};
like $json->{json_error}, qr/doesn't exist or you can't access it/, 'Error is shown';


$mockAtheme->mock ( 'command', sub {
    die RPC::Atheme::Error->new (1, "Test error");
});

$ua->get("http://localhost/json/group/1/listchans", "Listing channels page");

my $json = decode_json($ua->content);
ok !$json->{json_success};

is $json->{json_error}, 'Could not talk to Atheme: Test error', 'Error is shown';

done_testing;
