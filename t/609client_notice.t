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

my @return;

$mock->mock ( 'command' => sub {
    my (undef, undef, $command, $channel, $notice) = @_;

    push @return, ($command, $channel, $notice);
});

my $client = GMS::Atheme::Client->new ( $mock );
$client->notice_chan('#test', ('hello', 'hi'));

is_deeply
    \@return,
    [
        'noticechan',
        '#test',
        'hello',
        'noticechan',
        '#test',
        'hi'
    ],
    'Notice chan calls the right command';

@return = ();

$client->notice_staff_chan('Meep');

is_deeply
    \@return,
    [
        'noticechan',
        '#freenode-ponies42',
        'Meep'
    ],
    'Notice staff chan uses the right channel';

done_testing;
