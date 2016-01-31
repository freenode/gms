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
my $group = $schema->resultset('Group')->find({ 'id' => 2 });

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

#:throws_ok { $change->approve ($admin) } qr /Can't approve a change that isn't a request/, 'We can only approve changes that are requests';

eval {
    $schema->resultset('CloakChange')->create({ });
};

my $error = $@;

ok $error;

is_deeply $error->message, [
    "target must be specified",
    "requestor must be specified",
    "Cloak must be provided",
    "Changed by must be provided"
];

throws_ok {
    $schema->resultset('CloakChange')->create({
            'target'     => '3EAB67EC',
            'requestor'  => '3EAB67EC',
            'cloak'      => 'ns/@#!$@_',
            'changed_by' => '3EAB67EC',
            'group'      => $group,
        })
} qr/The role\/user contains invalid characters. Only alphanumeric characters, dash and slash are allowed./;

throws_ok {
    $schema->resultset('CloakChange')->create({
            'target'     => '3EAB67EC',
            'cloak'      => 'ns/LoremipsumdolorsitametconsecteturadipiscingelitMaurisegetrutrummf',
            'changed_by' => '3EAB67EC',
        })
} qr/The cloak is too long/;

throws_ok {
    $schema->resultset('CloakChange')->create({
            'target'     => '3EAB67EC',
            'cloak'      => 'cloak/',
            'changed_by' => '3EAB67EC',
        })
} qr#\(Role/\)user must be provided#;

throws_ok {
    $schema->resultset('CloakChange')->create({
            'target'     => '3EAB67EC',
            'cloak'      => 'cloak/foo/bar/',
            'changed_by' => '3EAB67EC',
        })
} qr/The cloak cannot end with a slash/;

throws_ok {
    $schema->resultset('CloakChange')->create({
            'target'     => '3EAB67EC',
            'cloak'      => 'cloak/42',
            'changed_by' => '3EAB67EC',
        })
} qr/The cloak provided looks like a CIDR mask/;

throws_ok {
    $schema->resultset('CloakChange')->create({
            'target'     => '3EAB67EC',
            'cloak'      => 'cloak/42/is-ok',
            'changed_by' => '3EAB67EC',
        })
} qr/You need to provide a group/;

throws_ok {
    $schema->resultset('CloakChange')->create({
            'target'     => '3EAB67EC',
            'cloak'      => 'cloak/42/is-ok',
            'group'      => $group,
            'changed_by' => '3EAB67EC',
        })
} qr/does not belong in your Group's namespaces/;

lives_ok {
    $schema->resultset('CloakChange')->create({
            'target'     => '3EAB67EC',
            'requestor'  => '3EAB67EC',
            'cloak'      => 'group0/42/is-ok',
            'group'      => $group,
            'changed_by' => '3EAB67EC',
        })
};

my $pending = $schema->resultset('CloakChange')->search_pending;

is $pending->count, 17, "17 pending requests";

my $req = $pending->find({ "namespace.namespace" => "group40" }, { join => "namespace" });

ok $req, 'Request exists';

$req->namespace->change ($admin, 'workflow_change', { status => 'deleted' });

$pending = $schema->resultset('ChannelRequest')->search_pending;
$req = $pending->find({ "namespace.namespace" => "group0" }, { join => "namespace" });

ok !$req, 'Request is not valid anymore, since the namespace is gone';

is $pending->count, 16;

warn $pending->count;

done_testing;
