#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockModule;
use Test::MockObject;

use RPC::Atheme::Error;
use lib qw(t/lib);
use GMSTest::Common;

use GMS::Domain::GroupContact;
use GMS::Exception;

my $mockContact = new Test::MockModule('GMS::Domain::Contact');
$mockContact->mock ('new', sub {
        'Test contact'
    });

my $mockSession = new Test::MockObject;
my $mockSchema = new Test::MockObject;

$mockSchema->mock ('result_source', sub {
        $mockSchema;
    });

$mockSchema->mock ('schema', sub {
    });

$mockSchema->mock ('contact', sub {
        $mockSchema;
    });

$mockSchema->mock ('id', sub {
    });

my $ns = GMS::Domain::GroupContact->new ($mockSession, $mockSchema);
is $ns->contact, 'Test contact', 'Retrieving a GMS::Domain::Contact object for changed_by works';


$mockContact->mock ('new', sub {
        die GMS::Exception->new ("Test error");
    });

throws_ok {
    GMS::Domain::GroupContact->new ($mockSession, $mockSchema);
} qr/Test error/, "Errors are thrown";

$mockContact->mock ('new', sub {
        die RPC::Atheme::Error->new (1, "Test error");
    });

throws_ok {
    GMS::Domain::GroupContact->new ($mockSession, $mockSchema);
} qr/Test error/, "Errors are thrown";

done_testing;
