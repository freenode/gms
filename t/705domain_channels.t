#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockModule;
use Test::MockObject;

use RPC::Atheme::Error;
use lib qw(t/lib);
use GMSTest::Common;

use GMS::Domain::Channels;
use Data::Dumper;

my $mockSchema = Test::MockObject->new;

$mockSchema->mock ('create', sub {
        shift @_;
        @_;
    });
$mockSchema->mock ('resultset', sub {
        $mockSchema;
    });

my $mockClient = new Test::MockModule('GMS::Atheme::Client');

$mockClient->mock ('chanexists', sub {
        1;
    });

my $channels = GMS::Domain::Channels->new ( undef, $mockSchema );

my @results = $channels->request ( { channel => '#test' });
is_deeply \@results, [
    {
        channel => '#test'
    }
], 'Creating a channel request would work';

$mockClient->mock ('chanexists', sub {
        0;
    });

throws_ok {
    $channels->request ( { channel => '#test' });
} qr /#test isn't registered/, "Can't have a request on an unregistered channel";

$mockClient->mock ('chanexists', sub {
        die RPC::Atheme::Error->new (1, "Test error");
    });

throws_ok {
    $channels->request ( { channel => '#test' });
} qr /Test error/, "Atheme errors thrown back";

done_testing;
