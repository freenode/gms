#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

# Define the group registration workflow.

my $schema = need_database 'basic_db';
ok $schema, "Connect to and set up database";

my $user = $schema->resultset('Account')->search({ accountname => 'test01' })->single;
ok $user, "Found user account";

my $admin = $schema->resultset('Account')->search({ accountname => 'admin01' })->single;
ok $admin, "Found admin account";

# First, submit the group application. Check that its initial state is correct.

my $group = $schema->resultset('Group')->create({
        account => $user,
        group_type => 'informal',
        group_name => 'Test Group',
        url => 'http://www.example.com',
        address => undef,
    });

isa_ok $group, "GMS::Schema::Result::Group";

# This should really be done automatically
#ok $group->add_to_group_contacts({ contact => $user->contact });
ok $group->add_to_contacts($user->contact);

is $group->status, 'submitted';
is $group->contacts->count, 1;
is $group->contacts->single->id, $user->contact->id;

is $group->group_changes->count, 1;
is $group->group_changes->single->changed_by->id, $user->id;
is $group->group_changes->single->change_type, 'create';

# Verify the group.
ok $group->verify($admin);
is $group->status, 'verified';
is $group->group_changes->count, 2;
is $group->active_change->change_type, 'admin';

# Double verification fails
throws_ok { $group->verify($admin) }
          qr/Can't verify a group that isn't pending verification/,
          "Can't verify a verified group";

is $schema->resultset('Group')->active_groups->count, 0,
        "Verified group isn't active";

ok $group->approve($admin);
is $group->status, 'active';
is $group->group_changes->count, 3;
is $group->active_change->change_type, 'admin';

is $schema->resultset('Group')->active_groups->count, 1,
        "Approved group becomes active";

# Can't reject something already approved
throws_ok { $group->reject($admin) }
          qr/Can't reject a group not pending approval/,
          "Can't reject approved group";


done_testing;
