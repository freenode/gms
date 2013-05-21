#!/usr/bin/perl
use strict;
use warnings;
use RPC::Atheme::Error;
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
my $user = $schema->resultset('Account')->find({ 'accountname' => 'test01' });

# just add the namespace with 'active' status, we don't need to test admin approval at this point.

my $namespace = $group->add_to_channel_namespaces ({ 'group_id' => $group->id, 'account' => $user, 'namespace' => 'test', 'status' => 'active' });

my $mock = Test::MockObject->new;

$mock->mock ( 'user' => sub { $mock } );
$mock->mock ( 'model' => sub { $mock } );
$mock->mock ( 'session' => sub { $mock });
$mock->mock ( 'account' => sub { $user } );
$mock->mock ( 'command', sub {
        shift @_; #we don't need the first element, which is a Test::MockObject
        return @_;
    });

my @result = $group->take_over ($mock, "#test", "test", $user->accountname);

is_deeply ( \@result, [
    "GMSServ",
    "transfer",
    "#test",
    "test01",
    "test01"
], "Test taking over channels" );

my $random = random_string("cccccccc");

@result = $group->take_over ($mock, "#test-$random", "test", $user->accountname);

is_deeply ( \@result, [
    "GMSServ",
    "transfer",
    "#test-$random",
    "test01",
    "test01"
], "Test taking over channel in the namespace with random name" );

throws_ok {
    $group->take_over ($mock, "#test2", "test2", $user->accountname);
} qr/This namespace does not belong in your Group's namespaces/, 'Using a namespace your group doesn\'t own fails';

throws_ok {
    $group->take_over ($mock, "#test2", "test", $user->accountname);
} qr/This channel does not belong in that namespace/, 'Taking over a channel not in the namespace fails';

@result = $group->drop ($mock, "#test", "test");

is_deeply ( \@result, [
    "GMSServ",
    "drop",
    "#test",
    "test01"
], "Test dropping channels" );

$random = random_string("cccccccc");

@result = $group->drop ($mock, "#test-$random", "test");

is_deeply ( \@result, [
    "GMSServ",
    "drop",
    "#test-$random",
    "test01",
], "Test dropping a channel in the namespace with random name" );

throws_ok {
    $group->drop ($mock, "#test2", "test2");
} qr/This namespace does not belong in your Group's namespaces/, 'Using a namespace your group doesn\'t own fails';

throws_ok {
    $group->drop ($mock, "#test2", "test");
} qr/This channel does not belong in that namespace/, 'Dropping a channel not in the namespace fails';

$mock->mock ( 'command', sub {
        die new RPC::Atheme::Error;
    });

throws_ok {
    $group->take_over ($mock, "#test-$random", "test", $user->accountname);
} "RPC::Atheme::Error", "Atheme errors are thrown back";

throws_ok {
    $group->drop ($mock, "#test-$random", "test");
} "RPC::Atheme::Error", "Atheme errors are thrown back";

$mock->mock ( 'command', sub {
        die "Test Error";
    });

throws_ok {
    $group->take_over ($mock, "#test-$random", "test", $user->accountname);
} qr/Test Error/, "Other errors are also thrown back";

throws_ok {
    $group->drop ($mock, "#test-$random", "test");
} qr/Test Error/, "Other errors are also thrown back";

done_testing;
