#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'three_contacts';

my $account = $schema->resultset('Account')->search({ accountname => 'test01' })->single;
isa_ok $account, 'GMS::Schema::Result::Account';

my $account2 = $schema->resultset('Account')->search({ accountname => 'test02' })->single;
isa_ok $account2, 'GMS::Schema::Result::Account';

my $account3 = $schema->resultset('Account')->search({ accountname => 'test03' })->single;
isa_ok $account3, 'GMS::Schema::Result::Account';

my $adminaccount = $schema->resultset('Account')->search({ accountname => 'admin01' })->single;
isa_ok $adminaccount, 'GMS::Schema::Result::Account';

my $contact = $account->contact;
isa_ok $contact, 'GMS::Schema::Result::Contact';

my $group = $schema->resultset('Group')->search({ group_name => 'test' })->single;
isa_ok $group, 'GMS::Schema::Result::Group', 'Found group';

#
# Test change semantics for GroupContact.
#
# Inviting a contact creates a GroupContact object which is not yet active.
# Only once a status change is requested and active does the new contact appear
# in $group->active_contacts.
#

is $group->contacts->count, 1;
is $group->active_contacts->count, 1;

my $gc = $group->group_contacts->single;
ok $gc;

is $gc->id, '1_1', 'Make sure we find the right contact';
is $gc->is_primary, 1, 'First added contact is primary';

$gc = $schema->resultset('GroupContact')->find_by_id ( '1_1' );
ok $gc, 'find_by_id_works';

is $gc->id, '1_1', 'find_by_id works';

$group->invite_contact($account2->contact, $account);

is $group->contacts->count, 2;
is $group->active_contacts->count, 1;

my $invited_group_contact = $group->group_contacts->search_status('invited')->single;
isa_ok $invited_group_contact, 'GMS::Schema::Result::GroupContact';
$invited_group_contact->change($account2, 'workflow_change', { status => 'pending_staff' });

is $schema->resultset('GroupContact')->search_pending->count, 1, 'search_pending works';

is $group->contacts->count, 2;
is $group->active_contacts->count, 1;

$invited_group_contact->reject ($adminaccount);

is $schema->resultset('GroupContact')->search_pending->count, 0, 'search_pending decreases on rejecting';

$group->discard_changes;

is $group->contacts->count, 2;
is $group->active_contacts->count, 1;

$group->invite_contact ($account2->contact, $account);
$invited_group_contact->change ($account2, 'workflow_change', { 'status' => 'pending_staff' });

is $schema->resultset('GroupContact')->search_pending->count, 1, 'search_pending works';

$invited_group_contact->approve ($adminaccount);

is $schema->resultset('GroupContact')->search_pending->count, 0, 'search_pending decreases on approving';

throws_ok { $group->invite_contact ( $account2->contact, $account ) } qr/This person has already been invited/, "Can't invite the same person twice.";
throws_ok { $group->add_contact ( $account2->contact, $adminaccount ) } qr/This person has already been added/, "Can't add existing group contact.";

$group->discard_changes;

is $group->contacts->count, 2;
is $group->active_contacts->count, 2;

is $invited_group_contact->is_primary, 0, 'Other added contacts are not primary by default.';

$invited_group_contact->change ( $adminaccount, 'admin', { 'primary' => 1 } );

is $invited_group_contact->is_primary, 1, 'We can change the primary status of a gc.';

ok $group->add_contact ( $account3->contact, $adminaccount, { 'primary' => 1 }), 'Administrators adding contacts works';

$gc = $group->group_contacts->search ({ 'contact_id' => 3 })->single;
isa_ok $gc, 'GMS::Schema::Result::GroupContact';

is $gc->is_primary, 1, 'We can force an added gc to be primary.';

ok $gc->change ( $account3, 'request', { 'primary' => -1 });

is $gc->is_primary, 1, 'Requests are not active changes.';

my $change = $gc->change ( $adminaccount, 'admin', { 'primary' => -1 });
ok $change;

is $gc->is_primary, 0, "We can remove a gc's primary status";

throws_ok { $gc->approve ($adminaccount) } qr/Can't approve a group contact not pending approval/, "Can't approve a group contact not pending approval";
throws_ok { $gc->reject ($adminaccount) } qr/Can't reject a group contact not pending approval/, "Can't reject a group contact not pending approval";

throws_ok { $change->approve ($adminaccount) } qr/Can't approve a change that isn't a request/, "Can't approve a change that isn't a request";
throws_ok { $change->reject ($adminaccount) } qr/Can't reject a change that isn't a request/, "Can't reject a change that isn't a request";

$change = $gc->change ( $account3, 'request', { 'primary' => 1 });

throws_ok { $change->approve } qr/Need an account to approve a change/, "Need an account to approve a change";
throws_ok { $change->reject } qr/Need an account to reject a change/, "Need an account to reject a change";

ok $change->approve ($adminaccount), 'Approving changes works.';
$gc->discard_changes;

is $gc->is_primary, 1, 'Change has been applied';

$change = $gc->change ( $account3, 'request', { 'primary' => -1 });

ok $change->reject ($adminaccount), 'Rejecting changes works.';
$gc->discard_changes;

is $gc->is_primary, 1, 'Change has not been applied';

ok $gc->change ( $adminaccount, 'admin',  { 'status' => 'deleted' });

$group->invite_contact ( $account3->contact, $account, { 'primary' => 1 } );
$gc->discard_changes;

is $gc->status->is_invited, 1, 'gc is invited';
is $gc->is_primary, 1, 'We can invite a group contact that has primary status from the start';

done_testing;
