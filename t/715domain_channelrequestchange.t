#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockModule;
use Test::MockObject;

use RPC::Atheme::Error;
use lib qw(t/lib);
use GMSTest::Common;

use GMS::Domain::ChannelRequestChange;
use GMS::Exception;

my $mockAccounts = new Test::MockModule('GMS::Domain::Accounts');
$mockAccounts->mock ('find_by_uid', sub {
        'Test account'
    });

my $mockCloakChange = new Test::MockModule('GMS::Domain::ChannelRequest');
$mockCloakChange->mock ('new', sub {
        'Test channel request'
    });

my $mockSession = new Test::MockObject;
my $mockSchema = new Test::MockObject;

$mockSchema->mock ('result_source', sub {
        $mockSchema;
    });


$mockSchema->mock ('schema', sub {
    });

$mockSchema->mock ('changed_by', sub {
        $mockSchema;
    });

$mockSchema->mock ('channel_request', sub {
        $mockSchema;
    });

$mockSchema->mock ('id', sub {
    });

my $ns = GMS::Domain::ChannelRequestChange->new ($mockSession, $mockSchema);
is $ns->changed_by, 'Test account', 'Retrieving a GMS::Domain::Account object for changed_by works';
is $ns->channel_request, 'Test channel request', 'Retrieving a GMS::Domain::ChannelRequest for channel_request works.';

$mockAccounts->mock ('find_by_uid', sub {
        die GMS::Exception->new ("Test error");
    });

throws_ok {
    GMS::Domain::ChannelRequestChange->new ($mockSession, $mockSchema);
} qr/Test error/, "Errors are thrown";

$mockAccounts->mock ('find_by_uid', sub {
        die RPC::Atheme::Error->new (1, "Test error");
    });

throws_ok {
    GMS::Domain::ChannelRequestChange->new ($mockSession, $mockSchema);
} qr/Test error/, "Errors are thrown";

done_testing;
