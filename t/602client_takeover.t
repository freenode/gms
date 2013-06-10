#!/usr/bin/perl
use strict;
use warnings;
use RPC::Atheme::Error;
use Test::Most;
use Test::MockObject;

use lib qw(t/lib);
use GMS::Atheme::Client;
use GMSTest::Common;

use String::Random qw/random_string/;

my $mock = Test::MockObject->new;

$mock->mock ( 'user' => sub { $mock } );
$mock->mock ( 'model' => sub { $mock } );
$mock->mock ( 'session' => sub { $mock });
$mock->mock ( 'service' => sub { 'GMSServ' } );
$mock->mock ( 'command', sub {
        shift @_; #we don't need the first element, which is a Test::MockObject
        return @_;
    });


my $client = GMS::Atheme::Client->new ( $mock );
my @result = $client->take_over ("#test", 'AAAAAAAAP', 'AAAAAAAAP');

is_deeply ( \@result, [
    "GMSServ",
    "transfer",
    "#test",
    "AAAAAAAAP",
    "AAAAAAAAP"
], "Test taking over channels" );

my $random = random_string("cccccccc");

@result = $client->drop ("#test",'AAAAAAAAP');

is_deeply ( \@result, [
    "GMSServ",
    "drop",
    "#test",
    "AAAAAAAAP"
], "Test dropping channels" );

$mock->mock ( 'command', sub {
        die new RPC::Atheme::Error;
    });

throws_ok {
    $client->take_over ("#test-$random", 'AAAAAAAAP', 'AAAAAAAAP');
} "RPC::Atheme::Error", "Atheme errors are thrown back";

throws_ok {
    $client->drop ("#test-$random", 'AAAAAAAAP');
} "RPC::Atheme::Error", "Atheme errors are thrown back";

done_testing;
