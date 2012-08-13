#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockObject;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

use String::Random qw/random_string/;

use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

my $schema = need_database 'three_groups';

my $group = $schema->resultset('Group')->find ({ 'group_name' => 'group01' });
my $user = $schema->resultset('Account')->find({ 'accountname' => 'test02' });

# just add the namespace with 'active' status, we don't need to test admin approval at this point.

my $namespace = $group->add_to_cloak_namespaces ({ 'group_id' => $group->id, 'account' => $user, 'namespace' => 'test', 'status' => 'active' });

my $mock = Test::MockObject->new;

$mock->mock ( 'model' => sub { $mock } );
$mock->mock ( 'session' => sub { $mock });
$mock->mock ( 'command', sub {
        shift @_; #we don't need the first element, which is a Test::MockObject
        return @_;
    });

my $cloak = "test/" . random_string("cccccccc");

my $change = $schema->resultset('CloakChange')->create ({ contact_id => $user->contact->id, cloak => "$cloak", changed_by => $user, offered => \"NOW()" });

ok $change->accept;

my @result = $change->approve ($mock);

is_deeply ( \@result, [
   "GMSServ",
   "cloak",
   "test02",
   $cloak
], "Test setting cloaks");

done_testing;
