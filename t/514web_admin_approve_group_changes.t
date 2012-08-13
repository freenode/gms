use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $change_rs = $schema->resultset('GroupChange');

my $change5 = $change_rs->find({ 'id' => 5 });
my $change14 = $change_rs->find({ 'id' => 14 });

my $group1 = $change5->group;
my $group2 = $change14->group;

is $group1->address, undef, 'right now, the group has no address.';
is $group2->address, undef, 'right now, the group has no address.';

ok $group1->group_type->is_informal, 'the group is informal';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->get_ok("http://localhost/admin/approve_change", "Change approval page works");

$ua->submit_form(
    fields => {
        change_item => 2
    }
);

$ua->submit_form(
    fields => {
        action_5 => 'approve',
        action_14 => 'approve'
    }
);

$group1->discard_changes;
$group2->discard_changes;

ok $group1->last_change->change_type->is_approve, 'last change is approved';
is $group1->address->id, 5, 'address is now 5';
ok $group1->group_type->is_government, 'group type is now government';

ok $group2->last_change->change_type->is_approve, 'last change is approved';
is $group2->address->id, 7, 'address is now 7';

is $group1->last_change->affected_change->id, 5, 'affected change is correct';
is $group2->last_change->affected_change->id, 14, 'affected change is correct';

done_testing;
