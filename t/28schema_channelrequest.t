#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;
use Test::MockModule;
use lib qw(t/lib);

use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'new_db';

my $group = $schema->resultset('Group')->find({ 'group_name' => 'group020' });
my $user = $schema->resultset('Account')->find ({ 'accountname' => 'account0' });
my $admin = $schema->resultset('Account')->find({ 'accountname' => 'admin' });

is $schema->resultset('ChannelRequest')->search_pending->count, 16, '16  pending requests at first.';

ok $admin;

eval {
    $schema->resultset('ChannelRequest')->create({ });
};

my $error = $@;
isa_ok $error, 'GMS::Exception::InvalidChannelRequest';

is_deeply $error->errors, [
    'Requestor must be specified',
    'Request Type must be provided',
    'Channel must be provided',
    'Namespace must be provided',
    'Group must be provided',
    'Changed by must be provided'
], "Errors are thrown if we don't provide arguments";

throws_ok {
    $schema->resultset('ChannelRequest')->create({
            requestor    => $user->contact,
            request_type => 'transfer',
            channel      => '#group0',
            namespace    => 'group0',
            group        => $group,
            changed_by   => $user,
        });
} qr/Target must be provided/, 'Target is required for transfer';

my $request = $schema->resultset('ChannelRequest')->create({
            requestor    => $user->contact,
            request_type => 'drop',
            channel      => '#group0',
            namespace    => 'group0',
            group        => $group,
            changed_by   => $user,
        });

ok $request, 'Target is not required for drop';

throws_ok {
    $schema->resultset('ChannelRequest')->create({
            requestor    => $user->contact,
            request_type => 'transfer',
            channel      => '#group0',
            namespace    => 'group1',
            group        => $group,
            changed_by   => $user
        });
} qr/This namespace does not belong in your Group's namespaces/, 'Cannot use a namespace we do not have';

throws_ok {
    $schema->resultset('ChannelRequest')->create({
            requestor    => $user->contact,
            request_type => 'transfer',
            channel      => '#group1',
            namespace    => 'group0',
            group        => $group,
            changed_by   => $user
        });
} qr/This channel does not belong in that namespace/, 'Cannot use the wrong namespace';

is $schema->resultset('ChannelRequest')->search_pending->count, 17, '17 pending requests';

ok $request->reject($admin), "Rejecting a request works";
ok $request->active_change->status->is_rejected, "Rejecting works";

ok $request->change ($admin, { status => 'error' });
ok $request->apply($admin), "Marking as applied works";

ok $request->active_change->status->is_applied, "Marking as applied works";

ok $request->change ($admin, { status => 'approved' });
ok $request->active_change->status->is_approved, "Marking as approved works";

is $schema->resultset('ChannelRequest')->search_unapplied->count, 1, '1 unapplied request';

ok $request->change ($admin, { status => 'pending_staff' });

my $mockClient = new Test::MockModule('GMS::Atheme::Client');
our @data;

$mockClient->mock ('drop', sub {
    shift @_;
    @data = @_;
});

$request->approve(undef, $admin);
$request->discard_changes;

ok $request->active_change->status->is_applied, "Approving syncs to atheme, and if that succeeds it's applied";

is_deeply \@data, [
    '#group0',
    '3EAB67EC'
];

$mockClient->mock ('take_over', sub {
    shift @_;
    @data = @_;
});

$request = $schema->resultset('ChannelRequest')->create({
            requestor    => $user->contact,
            request_type => 'transfer',
            channel      => '#group0',
            namespace    => 'group0',
            group        => $group,
            changed_by   => $user,
            target       => $user
        });

$request->approve (undef, $admin);
$request->discard_changes;

ok $request->active_change->status->is_applied, "Approving syncs to atheme, and if that succeeds it's applied";

is_deeply \@data, [
    '#group0',
    '3EAB67EC',
    '3EAB67EC'
];

ok $request->change ($admin, { status => 'pending_staff' });

$mockClient->mock ('take_over', sub {
    die RPC::Atheme::Error->new (1, "Test error");
});

$request->approve (undef, $admin);
$request->discard_changes;

ok $request->active_change->status->is_error, "Approving syncs to atheme, and if that fails the status is error";
ok $request->active_change->change_freetext =~ 'Test error', 'Error message is recorded';

$mockClient->mock ('new', sub {
    die RPC::Atheme::Error->new (1, "Test error 2");
});

$request->approve (undef, $admin);
$request->discard_changes;

ok $request->active_change->status->is_error, "Approving syncs to atheme, if we cannot construct a client record the error";
ok $request->active_change->change_freetext =~ 'Test error 2', 'Error message is recorded';

is $schema->resultset('ChannelRequest')->search_failed->count, 1, ' 1 failed request';

done_testing;
