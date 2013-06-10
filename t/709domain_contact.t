#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockModule;
use Test::MockObject;

use RPC::Atheme::Error;
use lib qw(t/lib);
use GMSTest::Common;

use GMS::Domain::Contact;
use GMS::Exception;

my $mockAccounts = new Test::MockModule('GMS::Domain::Accounts');
$mockAccounts->mock ('find_by_uid', sub {
        'Test account'
    });

my $mockSession = new Test::MockObject;
my $mockSchema = new Test::MockObject;

$mockSchema->mock ('result_source', sub {
        $mockSchema;
    });

$mockSchema->mock ('schema', sub {
    });

$mockSchema->mock ('account', sub {
        $mockSchema;
    });

$mockSchema->mock ('id', sub {
    });

my $ns = GMS::Domain::Contact->new ($mockSession, $mockSchema);
is $ns->account, 'Test account', 'Retrieving a GMS::Domain::Account object for account works';


$mockAccounts->mock ('find_by_uid', sub {
        die GMS::Exception->new ("Test error");
    });

throws_ok {
    GMS::Domain::Contact->new ($mockSession, $mockSchema);
} qr/Test error/, "Errors are thrown";

$mockAccounts->mock ('find_by_uid', sub {
        die RPC::Atheme::Error->new (1, "Test error");
    });

throws_ok {
    GMS::Domain::Contact->new ($mockSession, $mockSchema);
} qr/Test error/, "Errors are thrown";

done_testing;
