#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'three_groups';
my $user = $schema->resultset('Account')->find({ accountname => 'test01' });
my $admin = $schema->resultset('Account')->find({ accountname => 'admin01' });

ok $user;
ok $admin;

my $group1 = $schema->resultset('Group')->find({ 'group_name' => 'group01' });
my $group2 = $schema->resultset('Group')->find({ 'group_name' => 'group02' });
my $group3 = $schema->resultset('Group')->find({ 'group_name' => 'group03' });

ok $group1;
ok $group2;
ok $group3;

$group1->approve($admin);

throws_ok { $group1->verify($admin) }
          qr/Can't verify a group that isn't pending verification/,
          "Can't verify a verified group";

ok $group1->status->is_active;
ok $group1->active_change->change_type->is_admin;

throws_ok { $group1->verify($admin) }
          qr/Can't verify a group that isn't pending verification/,
          "Can't verify a verifieid group";

throws_ok { $group1->approve ($admin) }
          qr/Can't approve a group that isn't verified or pending verification/,
          "Can't approve an approved group";

throws_ok { $group1->reject ($admin) }
          qr/Can't reject a group not pending approval/,
          "Can't reject an approved group";


$group2->verify ($admin);

ok $group2->status->is_verified;

$group2->reject ($admin);

ok $group2->deleted;

throws_ok { $group2->verify($admin) }
          qr/Can't verify a group that isn't pending verification/,
          "Can't verify a rejected group";

throws_ok { $group2->approve ($admin) }
          qr/Can't approve a group that isn't verified or pending verification/,
          "Can't approve a rejected group";

throws_ok { $group2->reject ($admin) }
          qr/Can't reject a group not pending approval/,
          "Can't reject a rejected group";

throws_ok { $group3->verify($admin) }
          qr/Can't verify a group that isn't pending verification/,
          "Can't verify a group not pending verification";

throws_ok { $group3->approve ($admin) }
          qr/Can't approve a group that isn't verified or pending verification/,
          "Can't approve a group not pending approval";

throws_ok { $group3->reject ($admin) }
          qr/Can't reject a group not pending approval/,
          "Can't reject a group not pending approval";

done_testing;
