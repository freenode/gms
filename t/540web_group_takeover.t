use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
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
$mockAtheme->mock ( 'user' => sub { $mock } );
$mockAtheme->mock ( 'model' => sub { $mock } );
$mockAtheme->mock ( 'session' => sub { $mock });
$mockAtheme->mock ( 'service' => sub { 'GMSServ' } );
$mockAtheme->mock ( 'command', sub {
        1;
    });
$mockAtheme->mock ('login', sub {
        1;
    });

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

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

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#example-test',
        channel_namespace => 'example',
        action => 1,
        target => 'admin',
    }
);


$ua->content_contains ("Successfully requested the channel take over", "Transfer works");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        channel_namespace => 'example',
        action => 1,
        target => 'admin'
    }
);

diag $ua->content;

$ua->content_contains ("This channel does not belong in that namespace", "Errors are shown");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        channel_namespace => 'another',
        action => 1,
        target => 'admin'
    }
);

$ua->content_contains ("This namespace does not belong in your Group's namespaces.", "Errors are shown");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#example-test',
        channel_namespace => 'example',
        action => 2,
        target => 'admin',
    }
);

$ua->content_contains ("Successfully requested the channel drop", "Drop works");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        channel_namespace => 'example',
        action => 2,
        target => 'admin'
    }
);

$ua->content_contains ("This channel does not belong in that namespace", "Errors are shown");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        channel_namespace => 'another',
        action => 2,
        target => 'admin'
    }
);

$ua->content_contains ("This namespace does not belong in your Group's namespaces.", "Errors are shown");

done_testing;
