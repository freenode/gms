#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockModule;

use lib qw(t/lib);
use GMSTest::Common;
use GMS::Domain::Account;

my $account = GMS::Domain::Account->new ( 'AAAAAAAAH', 'erry' );

is $account->id, 'AAAAAAAAH';
is $account->accountname, 'erry';

my $mock = new Test::MockModule('GMS::Atheme::Client');
$mock->mock ('mark', sub {
        'Test mark'
    });

is $account->mark, 'Test mark';

done_testing;
