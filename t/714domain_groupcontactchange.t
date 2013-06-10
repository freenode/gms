#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockModule;
use Test::MockObject;

use RPC::Atheme::Error;
use lib qw(t/lib);
use GMSTest::Common;

use GMS::Domain::GroupContactChange;
use GMS::Exception;

my $mockAccounts = new Test::MockModule('GMS::Domain::Accounts');
$mockAccounts->mock ('find_by_uid', sub {
        'Test account'
    });

my $mockGC = new Test::MockModule('GMS::Domain::GroupContact');
$mockGC->mock ('new', sub {
        'Test GC'
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

$mockSchema->mock ('group_contact', sub {
        $mockSchema;
    });

$mockSchema->mock ('id', sub {
    });

my $ns = GMS::Domain::GroupContactChange->new ($mockSession, $mockSchema);
is $ns->changed_by, 'Test account', 'Retrieving a GMS::Domain::Account object for changed_by works';
is $ns->group_contact, 'Test GC', 'Retrieving group_contact works';

$mockAccounts->mock ('find_by_uid', sub {
        die GMS::Exception->new ("Test error");
    });

throws_ok {
    GMS::Domain::GroupContactChange->new ($mockSession, $mockSchema);
} qr/Test error/, "Errors are thrown";

$mockAccounts->mock ('find_by_uid', sub {
        die RPC::Atheme::Error->new (1, "Test error");
    });

throws_ok {
    GMS::Domain::GroupContactChange->new ($mockSession, $mockSchema);
} qr/Test error/, "Errors are thrown";

done_testing;
