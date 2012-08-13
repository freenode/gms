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

my $namespace = $group->add_to_cloak_namespaces ({ 'group_id' => $group->id, 'account' => $user, 'namespace' => "test" });

ok $namespace->status->is_pending_staff, 'Newly created cloak namespace is pending-staff';

is $schema->resultset('CloakNamespace')->search_pending->count, 1, 'Find pending namespace';

is $group->active_cloak_namespaces->count, 0, 'Namespace isn\'t active';

ok $namespace->approve ($admin);


throws_ok {
    $namespace->approve ($admin)
} qr/Can't approve a namespace that isn't pending approval/, "Can't approve an approved namespace";

throws_ok {
    $namespace->reject ($admin)
} qr/Can't reject a namespace not pending approval/, "Can't reject an approved namespace";

is $group->active_cloak_namespaces->count, 1, 'Namespace is active.';

ok $namespace->status->is_active, 'Namespace active change is active';

my $namespace2 = $group->add_to_cloak_namespaces ({ 'group_id' => $group->id, 'account' => $user, "namespace" => "test2" });

ok $namespace2->reject ($admin);

throws_ok {
    $namespace2->approve ($admin)
} qr/Can't approve a namespace that isn't pending approval/, "Can't approve a rejected namespace";

throws_ok {
    $namespace2->reject ($admin)
} qr/Can't reject a namespace not pending approval/, "Can't reject a rejected namespace";

is $group->active_cloak_namespaces->count, 1, 'Only the first namespace is active.';

ok $namespace2->status->is_deleted, 'Namespace active change is deleted';

done_testing;
