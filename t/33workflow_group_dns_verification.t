#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockObject;
use Test::MockModule;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

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

my $mock = Test::MockObject->new;

$mock->mock ('answer' => sub { $mock });
$mock->mock ('type'   => sub { 'CNAME' });
$mock->mock ('cname'  => sub { 'anything.freenode.net' });

my $mockDNS = Test::MockModule->new ('Net::DNS::Resolver');
$mockDNS->mock ('search', sub { $mock });

is $group->auto_verify ($user), 1, 'Verifying group via DNS works';

ok $group->status->is_pending_auto, 'Group status is now pending-auto after passing automatic verification';

$group = $schema->resultset('Group')->create({
        account => $user,
        group_type => 'informal',
        group_name => 'Test Group 2',
        url => 'http://example.com',
        address => undef,
    });

isa_ok $group, "GMS::Schema::Result::Group";

$mock->mock ('answer' => sub { $mock });
$mock->mock ('type'   => sub { 'CNAME' });
$mock->mock ('cname'  => sub { 'wrong.invalid' });

is $group->auto_verify ($user), -1, 'Wrong DNS returns -1';

$mock->mock ('answer' => sub { $mock });
$mock->mock ('type'   => sub { 'CNAME' });
$mock->mock ('cname'  => sub { 'wrong' });

is $group->auto_verify ($user), -1, 'Wrong DNS returns -1';

done_testing;
