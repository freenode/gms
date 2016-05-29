#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockObject;
use Test::MockModule;

use RPC::Atheme::Error;
use lib qw(t/lib);
use GMSTest::Common;
use GMS::Domain::Accounts;

my $mockAccount = new Test::MockModule('GMS::Domain::Account');
$mockAccount->mock ('new', sub {
        return @_;
    });

my $mockSession = Test::MockObject->new;

$mockSession->mock ('service', sub {
        'GMSServ';
    });

$mockSession->mock ('command', sub {
        my (undef, undef, $command, $param ) = @_;

        if ( $command eq 'accountname' ) {
            if ( $param eq 'AAAAAAAAH') {
                return 'erry';
            }
        } elsif ( $command eq 'uid' ) {
            if ( $param eq 'erry' ) {
                return 'AAAAAAAAH';
            }
        }
    });

my $mockSchema = Test::MockObject->new;

$mockSchema->mock ('resultset', sub {
        $mockSchema;
    });

$mockSchema->mock ('find', sub {
        $mockSchema;
    });

$mockSchema->mock ('find_or_new', sub {
        $mockSchema;
    });

$mockSchema->mock ('insert_or_update', sub {
        $mockSchema;
    });

$mockSchema->mock ('accountname', sub {
        'erry';
    });

$mockSchema->mock('dropped', sub { 0 });

$mockSchema->mock('uuid', sub { 'AAAAAAAAH'});
$mockSchema->mock('id', sub { 1} );

my $accounts = GMS::Domain::Accounts->new ( $mockSession, $mockSchema );

use Data::Dumper;

my @result = $accounts->find_by_uid ('1');

is_deeply \@result, [
    'GMS::Domain::Account',
    '1',
    'AAAAAAAAH',
    'erry',
    $mockSession,
    $mockSchema
];

@result = $accounts->find_by_name ('erry');

is_deeply \@result, [
    'GMS::Domain::Account',
    '1',
    'AAAAAAAAH',
    'erry',
    $mockSession,
    $mockSchema
];

$mockSchema->mock ('find', sub {
        $mockSchema;
    });
$mockSchema->mock ('dropped', sub {
        0;
    });

$accounts = GMS::Domain::Accounts->new ( $mockSession, $mockSchema );
@result = $accounts->find_by_uid ('1');

is_deeply \@result, [
    'GMS::Domain::Account',
    '1',
    'AAAAAAAAH',
    'erry',
    $mockSession,
    $mockSchema
], 'We stll get a GMS::Domain::Account if account && !account->dropped';;

$mockSchema->mock ('dropped', sub {
        1;
    });

@result = $accounts->find_by_uid ('1');

is_deeply \@result, [ $mockSchema ], 'If account is dropped we get the account from the schema';

our $dropped = 0;

$mockSchema->mock ('dropped', sub {
        my (undef, $drop) = @_;

        $dropped = $drop;
    });
$mockSchema->mock ('update', sub { });

$mockSession->mock ('command', sub {
        die RPC::Atheme::Error->new ( 4, 'No such account' );
    });

$accounts = GMS::Domain::Accounts->new ( $mockSession, $mockSchema );

$accounts->find_by_uid ('AAAAAAAAH');

is $dropped, 1, 'If the account doesn\'t exist in atheme, we\'re telling the db it is dropped';

throws_ok {
    $accounts->find_by_name;
} qr/Please provide an account name/, "Can't search without an account name";

throws_ok {
    $accounts->find_by_uid;
} qr/Please provide a user id/, "Can't search without a uid";

done_testing;
