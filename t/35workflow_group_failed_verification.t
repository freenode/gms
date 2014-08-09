#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::MockModule;

# Let's not make the test get stuck if web verification does,
# we don't care about it right now.
# let's also make sure it fails :)

my $mock_lwp = Test::MockModule->new('LWP::UserAgent');
$mock_lwp->mock('new', sub { my ($mock) = @_; return $mock; });
$mock_lwp->mock('request', sub { my ($mock) = @_; return $mock; });
$mock_lwp->mock('content', sub { return ''; });

my $mock_dns = Test::MockModule->new('Net::DNS::Resolver');
$mock_dns->mock('new', sub { my ($mock) = @_; return $mock; });
$mock_dns->mock('search', sub { return ''; });


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
