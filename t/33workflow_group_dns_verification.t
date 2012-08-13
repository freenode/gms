#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockObject;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

our ($file, $content);

my $schema = need_database 'basic_db';
my $user = $schema->resultset('Account')->search({ accountname => 'test01' })->single;

my $group = $schema->resultset('Group')->create({
        account => $user,
        group_type => 'informal',
        group_name => 'Test Group',
        url => 'http://example.com',
        address => undef,
    });

isa_ok $group, "GMS::Schema::Result::Group";

BEGIN {
    my $mock = Test::MockObject->new;

    $mock->fake_module (
        'Socket',
        'inet_ntoa' => sub { '140.211.167.100' },
        'inet_aton' => sub { 1 }, # since we're also faking inet_ntoa a nonzero value will suffice.
    );
}

is $group->auto_verify ($user), 1, 'Verifying group via DNS works';

ok $group->status->is_pending_auto, 'Group status is now pending-auto after passing automatic verification';

done_testing;
