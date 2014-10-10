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
        } elsif ($param2 eq '#example2-*') {
            return "\n- #example2-1 (test)\n \n";
        }
    }
});

$mockAtheme->mock ( 'service', sub { 'GMSServ' } );

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });


$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->get_ok("http://localhost/group/1/listchans", "Listing channels page");

$ua->content_contains('#example', 'List is shown immediatelly on 1 namespaces');
$ua->content_contains('#example-1', 'List is shown immediatelly on 1 namespaces');
$ua->content_contains('#example-2', 'List is shown immediatelly on 1 namespaces');

my $group = $schema->resultset('Group')->find({ id => 1 });
$group->add_to_channel_namespaces({ namespace => 'example2', 'group_id' => 1, 'status' => 'active', 'account' => 'AAAAAAAAP'});

$ua->get_ok("http://localhost/group/1/listchans", "Listing channels page");

$ua->content_lacks('#example', 'Now need to select namespace first');

$ua->submit_form(
    fields => {
        namespace => ''
    }
);

$ua->content_contains('#example', 'Listing all channels works');
$ua->content_contains('#example-1', 'Listing all channels works');
$ua->content_contains('#example-2', 'Listing all channels works');
$ua->content_contains('#example2-1', 'Listing all channels works');

$ua->get_ok("http://localhost/group/1/listchans", "Listing channels page");
$ua->submit_form(
    fields => {
        namespace => 'example2'
    }
);

$ua->content_lacks('#example-1', 'Listing specific namespace');
$ua->content_contains('#example2-1', 'Listing specific namespace');

$schema->resultset("ChannelRequest")->create({
        channel => '#example2-3',
        requestor => 1,
        namespace => 'example2',
        group => $group,
        request_type => 'transfer',
        target => 'AAAAAAAAP',
        changed_by => 'AAAAAAAAP'
    });

$ua->get_ok("http://localhost/group/1/listchans", "Listing channels page");
$ua->submit_form(
    fields => {
        namespace => 'example2',
    });

$ua->content_contains('example2-3', 'Pending requests are shown');

done_testing;
