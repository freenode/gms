#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockModule;
use Test::MockObject;

use RPC::Atheme::Error;
use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

use GMS::Domain::Group;
use GMS::Exception;

my $schema = need_database 'new_db';

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
my $row = $schema->resultset('Group')->find({ id => 149});

my $group = GMS::Domain::Group->new ( $mockSession, $row );

use Data::Dumper;

my @gcs = sort { $a->id cmp $b->id } $group->group_contacts;
is scalar @gcs, 2;

is $gcs[0]->contact->account->accountname, 'admin';
is $gcs[1]->contact->account->accountname, 'account49';

my @active_gcs = $group->active_group_contacts;

is scalar @active_gcs, 1;

is $active_gcs[0]->contact->account->accountname, 'account49';

my @editable_gcs = $group->editable_group_contacts;

is scalar @editable_gcs, 2, 'Retired gcs should show up here';

my @active_contacts = $group->active_contacts;

is scalar @active_contacts, 1;

is $active_contacts[0]->account->accountname, 'account49';

$mockGroupContact->mock ('new', sub {
        die GMS::Exception->new ("Test error");
    });

throws_ok {
    GMS::Domain::Group->new ($mockSession, $row);
} qr/Test error/, "Errors are thrown";

$mockGroupContact->mock ('new', sub {
        die RPC::Atheme::Error->new (1, "Test error");
    });

throws_ok {
    GMS::Domain::Group->new ($mockSession, $row);
} qr/Test error/, "Errors are thrown";

done_testing;
