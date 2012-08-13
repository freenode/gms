#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

my $schema = need_database 'basic_db';
my $user = $schema->resultset('Account')->search({ accountname => 'test01' })->single;

my $group = $schema->resultset('Group')->create({
        account => $user,
        group_type => 'informal',
        group_name => 'Test Group',
        url => 'http://example.com/',
        address => undef,
    });

isa_ok $group, "GMS::Schema::Result::Group";

is $group->auto_verify ($user), -1, 'Verification with no verify webpage, dns, or freetext fails.';

ok $group->status->is_pending_web, 'Group status is still pending_web.';

done_testing;
