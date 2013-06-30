#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'basic_db';
ok $schema, "Connect to and set up database";

my $user = $schema->resultset('Account')->search({ accountname => 'test01' })->single;
ok $user, "Found user account";

# Submit the group application. Check that its initial state is correct.

my $group = $schema->resultset('Group')->create({
        account => $user,
        group_type => 'informal',
        group_name => 'Test Group',
        url => 'http://www.example.com',
        address => undef,
    });

isa_ok $group, "GMS::Schema::Result::Group";

# This should really be done automatically
ok $group->add_contact($user->contact, $user);

ok $group->status->is_pending_web;
is $group->active_contacts->count, 1;
is $group->active_contacts->single->id, $user->contact->id;

is $group->group_changes->count, 1;
is $group->group_changes->single->changed_by->id, $user->id;
ok $group->group_changes->single->change_type->is_create;

done_testing;
