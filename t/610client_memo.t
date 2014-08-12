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
    my (undef, $service, $command, $user, $memo) = @_;

    return ($service, $command, $user, $memo);
});

my $client = GMS::Atheme::Client->new ( $mock );
my @return = $client->memo('erry', 'hello to you');


is_deeply
    \@return,
    [
        'MemoServ',
        'send',
        'erry',
        'hello to you',
    ],
    'Memo calls the right command';


done_testing;
