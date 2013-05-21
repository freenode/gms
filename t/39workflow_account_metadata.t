use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockObject;
use Carp::Always;
use RPC::Atheme::Error;
use Test::MockModule;
use Test::Exception;

my $schema = need_database 'basic_db';

my $mock = Test::MockObject->new();
$mock->mock ( 'user' => sub { $mock } );
$mock->mock ( 'model' => sub { $mock } );
$mock->mock ( 'session' => sub { $mock });
$mock->mock ( 'account' => sub { $user } );
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

my $useraccount = $schema->resultset('Account')->search({ accountname => 'test01' })->single;

my $data = $useraccount->metadata ( $mock, 'test' );
ok $data;

is $data, 'metadata test', 'Retrieving metadata works';

my $mark = $useraccount->mark ($mock);
ok $mark;

is_deeply $mark, [
    "test mark reason",
    "admin",
    "1362561337"
], "Retrieving marks works";

my $error = new Test::MockModule('RPC::Atheme::Error');

$error->mock (
     code, sub { RPC::Atheme::Error::nosuchkey() },
);
$error->mock ( 'PROPAGATE', sub { } );

$mock->mock ( 'command' => sub {
    shift @_ for 1 .. 2;

    my ($command, undef, $param) = ( @_ );

    if ( $command eq 'metadata' ) {
        die new RPC::Atheme::Error;
    }
});

lives_ok {  $useraccount->metadata ( $mock, 'test' ) }, 'Attempting to read metadata that does not exist does not die';
lives_ok { $useraccount->mark ($mock) }, 'Attemting to read a mark that does not exist does not die.';

$error->mock (
     code, sub { RPC::Atheme::Error::badparams() },
);
$error->mock ( 'PROPAGATE', sub { } );

$mock->mock ( 'command' => sub {
    shift @_ for 1 .. 2;

    my ($command, undef, $param) = ( @_ );

    if ( $command eq 'metadata' ) {
        die new RPC::Atheme::Error;
    }
});

throws_ok { $useraccount->metadata ( $mock, '' ) } "RPC::Atheme::Error", "Any other error would cause it to die.";
throws_ok { $useraccount->mark ( $mock ) } "RPC::Atheme::Error", "Any other error would cause it to die.";

$mock->mock ( 'command' => sub {
    shift @_ for 1 .. 2;

    my ($command, undef, $param) = ( @_ );

    if ( $command eq 'metadata' ) {
        die 'test';
    }
});

throws_ok { $useraccount->metadata ( $mock, '' ) } qr/test/, "Errors that aren't atheme should also be thrown back.";
throws_ok { $useraccount->mark ( $mock ) } qr/test/, "Errors that aren't atheme should also be thrown back.";

done_testing;
