#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'two_contacts';

my $account = $schema->resultset('Account')->search({ accountname => 'test01' })->single;
isa_ok $account, 'GMS::Schema::Result::Account';

my $account2 = $schema->resultset('Account')->search({ accountname => 'test02' })->single;
isa_ok $account2, 'GMS::Schema::Result::Account';

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

$group->invite_contact($account2->contact, $account);

is $group->contacts->count, 2;
is $group->active_contacts->count, 1;

my $invited_group_contact = $group->group_contacts->search_status('invited')->single;
isa_ok $invited_group_contact, 'GMS::Schema::Result::GroupContact';
$invited_group_contact->change($account2, 'workflow_change', { status => 'pending_staff' });

is $group->contacts->count, 2;
is $group->active_contacts->count, 1;

$invited_group_contact->reject ($adminaccount);

$group->discard_changes;

is $group->contacts->count, 2;
is $group->active_contacts->count, 1;

$group->invite_contact ($account2->contact, $account);
$invited_group_contact->change ($account2, 'workflow_change', { 'status' => 'pending_staff' });

$invited_group_contact->approve ($adminaccount);

$group->discard_changes;

is $group->contacts->count, 2;
is $group->active_contacts->count, 2;

done_testing;
