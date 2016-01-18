#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockObject;
use Test::MockModule;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

# Let's not make the test get stuck if web verification does, we don't care
# about it right now.  Also, we don't want it to somehow succeed since we're
# dong DNS verification instead.

my $mock_lwp = Test::MockModule->new('LWP::UserAgent');
$mock_lwp->mock('new', sub { my ($mock) = @_; return $mock; });
$mock_lwp->mock('request', sub { my ($mock) = @_; return $mock; });
$mock_lwp->mock('content', sub { return ''; });

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

my $mockRecord = Test::MockObject->new;
$mockRecord->mock ('char_str_list' => sub { $group->verify_dns });

my $mockResponse = Test::MockObject->new;
$mockResponse->mock ('answer' => sub { $mockRecord });

my $mockDNS = Test::MockModule->new ('Net::DNS::Resolver');
$mockDNS->mock ('search', sub { $mockResponse });

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

$mockRecord->mock ('char_str_list' => sub { });
$mockRecord->mock ('address' => sub { });

is $group->auto_verify ($user), -1, 'Wrong DNS returns -1';

$mockRecord->mock ('address' => sub { '127.0.0.127' });

is $group->auto_verify ($user), 1, 'Verifying group with A record works';

$mockRecord->mock ('address' => sub { });

is $group->auto_verify ($user), -1, 'Wrong DNS returns -1';


done_testing;
