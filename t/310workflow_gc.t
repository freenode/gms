#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'pending_changes';

my $account = $schema->resultset('Account')->search({ accountname => 'test01' })->single;
isa_ok $account, 'GMS::Schema::Result::Account';

my $admin = $schema->resultset('Account')->search({ accountname => 'admin01' })->single;
isa_ok $admin, 'GMS::Schema::Result::Account';

my $contact_id = $account->contact->id;

my @invitations = $schema->resultset("GroupContactChange")->active_invitations->search ( { 'contact_id' => $contact_id } );

my @groups;

foreach (@invitations) {
    push @groups, $_->group_id;
}

@groups = sort { $a <=> $b } @groups;

is_deeply \@groups, [
    1,
    2,
    3,
    5
], 'Retrieving group invitations works';

my $gc = $schema->resultset('GroupContact')->search({
        contact_id => 1,
        group_id => 1
    })->single;

ok $gc;

is $gc->id, '1_1', 'gc->id works';

is $gc->has_active_invitation, 1, 'The gc has an active invitation';

is $gc->can_access ($gc->group, 'group/2/edit'), 0, 'Can_access works';
is $gc->can_access ($gc->group, 'invite/accept'), 1, 'Can_access works';
is $gc->can_access ($gc->group, 'invite/decline'), 1, 'Can_access works';

ok $gc->accept_invitation;

is $gc->last_change->status->is_pending_staff, 1, 'Accepting invitation worked';

$gc = $schema->resultset('GroupContact')->search({
        contact_id => 1,
        group_id => 3
    })->single;

ok $gc;

ok $gc->decline_invitation;

is $gc->status->is_deleted, 1, 'gc is now deleted';
$gc = $schema->resultset('GroupContact')->search({
        contact_id => 1,
        group_id => 3
    })->single;

ok $gc;

is $gc->can_access ($gc->group, 'group/2/edit'), 1, 'Can access edit page of pending group.';

$gc->group->change ( $admin, 'admin', { 'status' => 'deleted' } );

is $gc->can_access ($gc->group, 'group/2/edit'), 0, 'Cannot access edit page of deleted group.';

$gc->group->change ( $admin, 'admin', { 'status' => 'active' } );

my $other_gc = $schema->resultset('GroupContact')->search({
        contact_id => 2,
        group_id => 1
    })->single;

ok $other_gc;

is $gc->can_access ($gc->group, 'group/2/view'), 0, 'Cannot access page of a group we do not belong to.';

$gc = $schema->resultset('GroupContact')->search({
        contact_id => 1,
        group_id => 4
    })->single;

ok $gc;

is $gc->can_access ($gc->group, 'group/4/edit'), 1, 'Active gc can access their active group';

is $gc->is_primary, 1;

is $gc->can_access ($gc->group, 'group/4/edit_gc'), 1, 'Primary gc can change gc information.';

$gc->change ( $admin, 'admin', { 'primary' => 0 } );

is $gc->can_access ($gc->group, 'group/4/edit_gc'), 0, 'non-primary gc cannot change gc information.';

done_testing;
