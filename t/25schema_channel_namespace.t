#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);

use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'three_groups';

my $group = $schema->resultset('Group')->find({ 'group_name' => 'group01' });
my $user = $schema->resultset('Account')->find ({ 'accountname' => 'test02' });
my $admin = $schema->resultset('Account')->find({ 'accountname' => 'admin01' });

ok $group;
ok $group->change ($admin, 'admin', { 'status' => 'active' });

my $namespace = $group->add_to_channel_namespaces ({ 'group_id' => $group->id, 'account' => $user, 'namespace' => "test" });

ok $namespace->status->is_pending_staff, 'Newly created channel namespace is pending-staff';

is $schema->resultset('ChannelNamespace')->search_pending->count, 1, 'Find pending namespace';

is $group->active_channel_namespaces->count, 0, 'Namespace isn\'t active';

is $namespace->group->id, $group->id, 'The namespace belongs to the correct group.';

ok $namespace->approve ($admin);

throws_ok {
    $namespace->approve ($admin)
} qr/Can't approve a namespace that isn't pending approval/, "Can't approve an approved namespace";

throws_ok {
    $namespace->reject ($admin)
} qr/Can't reject a namespace not pending approval/, "Can't reject an approved namespace";

is $group->active_channel_namespaces->count, 1, 'Namespace is active.';

ok $namespace->status->is_active, 'Namespace active change is active';

my $namespace2 = $group->add_to_channel_namespaces ({ 'group_id' => $group->id, 'account' => $user, "namespace" => "test2" });

ok $namespace2->reject ($admin);

throws_ok {
    $namespace2->approve ($admin)
} qr/Can't approve a namespace that isn't pending approval/, "Can't approve a rejected namespace";

throws_ok {
    $namespace2->reject ($admin)
} qr/Can't reject a namespace not pending approval/, "Can't reject a rejected namespace";

is $group->active_channel_namespaces->count, 1, 'Only the first namespace is active.';

ok $namespace2->status->is_deleted, 'Namespace active change is deleted';

my $namespace3 = $group->add_to_channel_namespaces ({ 'group_id' => $group->id, 'account' => $user, "namespace" => "test3", "status" => "active" });
ok $namespace3;

is $namespace3->status, 'active', 'We can create a new namespace to be already active';
is $group->active_channel_namespaces->count, 2, 'Group now has 2 active namespaces.';

my $change = $namespace3->change ($admin, 'admin', { 'group_id' => 3 });
ok $change;

throws_ok { $change->approve ($admin) } qr /Can't approve a change that isn't a request/, 'We can only approve changes that are requests';
throws_ok { $change->reject ($admin) } qr /Can't reject a change that isn't a request/, 'We can only reject changes that are requests';

is $namespace3->group->id, 3, "We can change a namespace's group";

$namespace3->change ($user, 'request', { 'status' => 'deleted' });
$change = $namespace3->change ($user, 'request', { 'group_id' => 2 });
ok $change;

is $namespace3->status, 'active', 'Requesting a status change does not make it happen unless approved.';
is $namespace3->group->id, 3, 'Requesting a status change does not make it happen unless approved.';

throws_ok { $change->approve } qr /Need an account to approve a change/, "We can't approve a change without providing the account approving it";
throws_ok { $change->reject } qr /Need an account to reject a change/, "We can't reject a change without providing the account rejecting it";

ok $change->approve ($admin);

$namespace3->discard_changes;

is $namespace3->status, 'deleted', 'Approving a status change makes it happen.';
is $namespace3->group->id, 2, 'Both changes have been applied by approving one of them - changes inherit previous changes';

eval {
    $group->add_to_channel_namespaces ({
            'group_id' => $group->id,
            'account' => $user,
            'namespace' => "Lorem ipsum dolor sit amet, consectetur massa nunc!"
        });
};
my $error = $@;
ok $error;

is_deeply $error->message, [
    "Channel namespaces must contain only alphanumeric characters, underscores, and dots.",
    "Channel namespaces can be no longer than 50 characters."
], 'Test field validation';

$change = $namespace3->change ($user, 'request', { 'status' => 'deleted' });
ok $change->reject ($admin);

is $schema->resultset("ChannelNamespaceChange")->active_requests->count, 0, 'No active requests at the moment.';

$change = $namespace3->change ($user, 'request', { 'status' => 'deleted' });

is $schema->resultset("ChannelNamespaceChange")->active_requests->count, 1, 'There is now an active request.';
is $schema->resultset("ChannelNamespaceChange")->active_requests->single->namespace->namespace, $namespace3->namespace, 'The active request belongs to the correct namespace.';

eval {
    GMS::Schema::Result::ChannelNamespaceChange->new({ });
};
$error = $@;
ok $error;

is_deeply $error->message, [
    "Group id cannot be empty",
    "Namespace status cannot be empty"
], "We can't create a ChannelNamespaceChange without the necessary arguments";

done_testing;
