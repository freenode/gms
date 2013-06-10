#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockModule;
use Test::MockObject;

use RPC::Atheme::Error;
use lib qw(t/lib);
use GMSTest::Common;

use GMS::Domain::Group;
use GMS::Exception;

my $mockContact = new Test::MockModule('GMS::Domain::Contact');
$mockContact->mock ('new', sub {
        my ( undef, undef, $row ) = @_;
        $row;
    });

my $mockGroupContact = new Test::MockModule('GMS::Domain::GroupContact');
$mockGroupContact->mock ('new', sub {
        my ( undef, undef, $row ) = @_;
        $row;
    });


my $mockSession = new Test::MockObject;
my $mockRow = new Test::MockObject;

$mockRow->mock ('group_contacts', sub {
        (
            'user1',
            'user2',
            'user3'
        )
    });
$mockRow->mock ('active_group_contacts', sub {
        (
            'user4',
            'user5'
        )
    });
$mockRow->mock ('editable_group_contacts', sub {
        (
            'user6',
            'user7'
        )
    });
$mockRow->mock ('active_contacts', sub {
        (
            'contact1',
            'contact2'
        )
    });

my $group = GMS::Domain::Group->new ( $mockSession, $mockRow );

my @gcs = $group->group_contacts;
is_deeply \@gcs, [ 'user1', 'user2', 'user3' ], 'Retrieving group contacts works';

my @active_gcs = $group->active_group_contacts;
is_deeply \@active_gcs, ['user4', 'user5'], 'Retrieving active gcs works';

my @editable_gcs = $group->editable_group_contacts;
is_deeply \@editable_gcs, ['user6', 'user7'], 'Retrieving editable gcs works';

my @active_contacts = $group->active_contacts;
is_deeply \@active_contacts, ['contact1', 'contact2'], 'Retrieving contacts works';

$mockContact->mock ('new', sub {
        die GMS::Exception->new ("Test error");
    });

throws_ok {
    GMS::Domain::Group->new ($mockSession, $mockRow);
} qr/Test error/, "Errors are thrown";

$mockContact->mock ('new', sub {
        die RPC::Atheme::Error->new (1, "Test error");
    });

throws_ok {
    GMS::Domain::Group->new ($mockSession, $mockRow);
} qr/Test error/, "Errors are thrown";

done_testing;
