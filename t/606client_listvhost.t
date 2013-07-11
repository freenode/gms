#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockObject;

use lib qw(t/lib);
use GMSTest::Common;
use GMS::Atheme::Client;

my $mock = Test::MockObject->new;

$mock->mock ( 'command' => sub {
    return "- admin test/cloak\n" .
    "- user test/anothercloak\n" .
    "2 Results total";
});

my $client = GMS::Atheme::Client->new ( $mock );
my %results = $client->listvhost(1);

is_deeply \%results,
    {
        'admin' => 'test/cloak',
        'user'  => 'test/anothercloak'
    }, 'Retrieving listvhost works';

throws_ok {
    $client->listvhost;
} qr/Please provide a search pattern/, 'Searching without pattern dies';

$mock->mock ( 'command' => sub {
    die RPC::Atheme::Error->new (1, 'Test error');
});

throws_ok {
    $client->listvhost(1);
} qr/Test error/, 'Errors are thrown back';

done_testing;
