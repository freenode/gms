#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;
use Test::MockObject;
use Test::MockModule;

use lib qw(t/lib);

use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'pending_changes';

my $cloakchange = $schema->resultset('CloakChange')->find({ 'id' => 2 });
my $user = $schema->resultset('Account')->find ({ 'accountname' => 'test01' });
my $admin = $schema->resultset('Account')->find({ 'accountname' => 'admin01' });

is $schema->resultset('CloakChange')->search_offered->count, 2;
is $schema->resultset('CloakChange')->search_pending->count, 2;

my $mock = Test::MockObject->new;

$mock->mock ( 'model' => sub { $mock } );
$mock->mock ( 'session' => sub { $mock });
$mock->mock ( 'command', sub {
        shift @_; #we don't need the first element, which is a Test::MockObject
        return @_;
    });

ok $cloakchange->accept;
$cloakchange->discard_changes;

is $schema->resultset('CloakChange')->search_offered->count, 2, 'An older cloak request is overwritten';
is $schema->resultset('CloakChange')->search_pending->count, 2, 'An older cloak request is overwritten';

ok $cloakchange->approve ($mock);

is $schema->resultset('CloakChange')->search_offered->count, 2, 'Cloaks pending user approval still the same';
is $schema->resultset('CloakChange')->search_pending->count, 1, 'Cloaks pending staff aproval decrease';

$cloakchange = $schema->resultset('CloakChange')->find({ 'id' => 2 });

ok $cloakchange->accept;
ok $cloakchange->reject;

my $error = new Test::MockModule('RPC::Atheme::Error');

$error->mock ( 'PROPAGATE', sub { } );

$mock->mock ( 'command', sub {
    die new RPC::Atheme::Error;
});

$cloakchange = $schema->resultset('CloakChange')->find({ 'id' => 3 });
$cloakchange->accept;

throws_ok { $cloakchange->approve ($mock) } "RPC::Atheme::Error", "Errors are thrown back";

$mock->mock ( 'command' => sub {
    die 'test';
});

throws_ok { $cloakchange->approve ($mock) } qr/test/, "Errors are thrown back";

done_testing;
