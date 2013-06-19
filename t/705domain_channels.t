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

$mockClient->mock ('chanregistered', sub {
        1;
    });

my $channels = GMS::Domain::Channels->new ( undef, $mockSchema );

my @results = $channels->request ( { channel => '#test', request_type => 'drop' });
is_deeply \@results, [
    {
        channel => '#test',
        request_type    => 'drop'
    }
], 'Creating a channel request would work';

$mockClient->mock ('chanexists', sub {
        1;
    });

@results = $channels->request ( { channel => '#test', request_type => 'transfer' });
is_deeply \@results, [
    {
        channel => '#test',
        request_type    => 'transfer'
    }
], 'Creating a channel request would work';

$mockClient->mock ('chanregistered', sub {
        0;
    });

throws_ok {
    $channels->request ( { channel => '#test', request_type => 'drop' });
} qr /#test isn't registered/, "Can't have a drop request on an unregistered channel";

$mockClient->mock ('chanexists', sub {
        0;
    });

throws_ok {
    $channels->request ( { channel => '#test', request_type => 'transfer' });
} qr /#test must exist/, "Can't have a transfer request on a nonexistant channel";

$mockClient->mock ('chanregistered', sub {
        die RPC::Atheme::Error->new (1, "Test error");
    });

throws_ok {
    $channels->request ( { channel => '#test', request_type => 'drop' });
} qr /Test error/, "Atheme errors thrown back";

done_testing;
