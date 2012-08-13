#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'basic_db';

my $account = $schema->resultset('Account')->find({ accountname => 'test01' });
isa_ok $account, 'GMS::Schema::Result::Account';

my $adminaccount = $schema->resultset('Account')->find({ accountname => 'admin01' });
isa_ok $adminaccount, 'GMS::Schema::Result::Account';

my $contact = $account->contact;
isa_ok $contact, 'GMS::Schema::Result::Contact';

my $original_name = $contact->name;
my $original_email = $contact->email;

my $new_name = 'Test Contact Changed';
my $new_email = 'changed@example.com';

my $change = $contact->change($account, 'request', { 'name' => $new_name,  'email' => $new_email });
isa_ok $change, 'GMS::Schema::Result::ContactChange';

is $contact->name, $original_name, "Requested change doesn't update active state";
is $contact->email, $original_email, "Requested change doesn't update active state";

$change->approve($adminaccount, "test");

$contact->discard_changes;

is $contact->active_change->name, $new_name, "Approving change updates active state";
is $contact->active_change->email, $new_email, "Approving change updates active state";

done_testing;
