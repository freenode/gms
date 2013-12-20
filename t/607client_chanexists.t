#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockObject;

use lib qw(t/lib);
use GMSTest::Common;
use GMS::Atheme::Client;

my $mock = Test::MockObject->new;

$mock->mock ( 'model' => sub { $mock } );
$mock->mock ( 'session' => sub { $mock });
$mock->mock ( 'service' => sub { 'GMSServ' } );

$mock->mock ( 'command' => sub {
    my (undef, undef, $command) = @_;

    if ($command eq 'chanexists') {
        return 1;
    }

    return 0;
});

my $client = GMS::Atheme::Client->new ( $mock );
my $result = $client->chanexists('#test');

ok $result;

$mock->mock ( 'command' => sub {
    my (undef, undef, $command) = @_;

    if ($command eq 'chanexists') {
        return -1;
    }

    return 1;
});

$result = $client->chanexists('#test');

ok !$result;

$mock->mock ( 'command' => sub {
    my (undef, undef, $command) = @_;

    if ($command eq 'chanexists') {
        die RPC::Atheme::Error->new (1, 'Test error');
    }

    return 1;
});

throws_ok {
    $client->chanexists(1);
} qr/Test error/, 'Errors are thrown back';

done_testing;
