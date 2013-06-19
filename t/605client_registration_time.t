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
    return 1371481337;
});

my $client = GMS::Atheme::Client->new ( $mock );

my $result = $client->registered(1);

is $result, 1371481337, "Retrieving registration time works";

$mock->mock ( 'command' => sub {
    return 1371489001;
});

$result = $client->lastlogin(1);

is $result, 1371489001, "Retrieving login time works";

$mock->mock ( 'command' => sub {
    return '1 day ago';
});

$result = $client->lastseen(1);

is $result, '1 day ago', 'Retrieving last seen time works';

done_testing;
