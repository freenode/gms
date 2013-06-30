#!/usr/bin/perl

use strict;
use warnings;

use Test::Exception;
use Test::Most;
use Test::MockModule;

use lib qw(t/lib);

use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'new_db';

my $cloakchange = $schema->resultset('CloakChange')->find({ 'id' => 1 });
my $user = $schema->resultset('Account')->find ({ 'accountname' => 'account0' });
my $admin = $schema->resultset('Account')->find({ 'accountname' => 'admin' });

is $schema->resultset('CloakChange')->search_offered->count, 8;
is $schema->resultset('CloakChange')->search_pending->count, 16;

my $mock = new Test::MockModule('GMS::Atheme::Client');

$mock->mock ( 'cloak', sub {
        return 1;
    });

ok $cloakchange->accept ( $user );
$cloakchange->discard_changes;

is $schema->resultset('CloakChange')->search_offered->count, 8, 'An older cloak request is overwritten';
is $schema->resultset('CloakChange')->search_pending->count, 17, 'Cloaks pending staff approval increase';

lives_ok  { $cloakchange->approve ( undef, $admin ); };

is $schema->resultset('CloakChange')->search_offered->count, 8, 'Cloaks pending user approval still the same';
is $schema->resultset('CloakChange')->search_pending->count, 16, 'Cloaks pending staff aproval decrease';

$cloakchange = $schema->resultset('CloakChange')->find({ 'id' => 2 });

ok $cloakchange->accept($user);
ok $cloakchange->reject($admin);

$mock->mock ( 'new', sub {
    die RPC::Atheme::Error->new(1, 'Test error');
});

$mock->unmock ('cloak');

$cloakchange = $schema->resultset('CloakChange')->find({ 'id' => 3 });
$cloakchange->accept ( $user );

$cloakchange->approve ( undef, $admin );
$cloakchange->discard_changes;

ok $cloakchange->active_change->status->is_error, "Status is changed to error";

done_testing;
