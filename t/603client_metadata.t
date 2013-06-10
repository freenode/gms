use lib qw(t/lib);
use GMSTest::Common;
use Test::More;
use Test::MockObject;
use GMS::Atheme::Client;
use RPC::Atheme::Error;
use Test::MockModule;
use Test::Exception;

my $mock = Test::MockObject->new();
$mock->mock ( 'user' => sub { $mock } );
$mock->mock ( 'model' => sub { $mock } );
$mock->mock ( 'session' => sub { $mock });
$mock->mock ( 'service' => sub { 'GMSServ' } );
$mock->mock ( 'command' => sub {
    shift @_ for 1 .. 2;
    my ($command, undef, $param) = ( @_ );

    if ( $command eq 'metadata' ) {
        if ($param eq 'private:mark:reason') {
            return "test mark reason";
        } elsif ($param eq 'private:mark:setter') {
            return "admin";
        } elsif ($param eq 'private:mark:timestamp') {
            return "1362561337";
        } elsif ($param eq 'test') {
            return "metadata test";
        }
    }
});


my $client = GMS::Atheme::Client->new ( $mock );
my $data = $client->metadata ( 'AAAAAAAAP', 'test' );
ok $data;

is $data, 'metadata test', 'Retrieving metadata works';

my $mark = $client->mark ( 'AAAAAAAAP' );
ok $mark;

is_deeply $mark, [
    "test mark reason",
    "admin",
    "1362561337"
], "Retrieving marks works";

$mock->mock ( 'command' => sub {
    shift @_ for 1 .. 2;

    my ($command, undef, $param) = ( @_ );

    if ( $command eq 'metadata' ) {
        die RPC::Atheme::Error->new (RPC::Atheme::Error::nosuchkey(), 'No such metadata');
    }
});

lives_ok { $client->metadata ( 'AAAAAAAAP', 'test' ) }, 'Attempting to read metadata that does not exist does not die';
lives_ok { $client->metadata ('AAAAAAAAP') }, 'Attemting to read a mark that does not exist does not die.';

$mock->mock ( 'command' => sub {
    shift @_ for 1 .. 2;

    my ($command, undef, $param) = ( @_ );

    if ( $command eq 'metadata' ) {
        die RPC::Atheme::Error->new (1, 'Test error');
    }
});

throws_ok { $client->metadata ( 'AAAAAAAAP', '' ) } "RPC::Atheme::Error", "Any other error would cause it to die.";
throws_ok { $client->mark ( 'AAAAAAAAP' ) } "RPC::Atheme::Error", "Any other error would cause it to die.";

done_testing;
