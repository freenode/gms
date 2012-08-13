use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $change_rs = $schema->resultset('ChannelNamespaceChange');

my $change15 = $change_rs->find({ 'id' => 15 });
my $change20 = $change_rs->find({ 'id' => 20 });

my $ns1 = $change15->namespace;
my $ns2 = $change20->namespace;

ok $ns1->status->is_deleted, 'namespace is deleted';
ok $ns2->status->is_deleted, 'namespace is deleted';

is $ns1->group->id, 4, 'namespace 1 group is 4';
is $ns2->group->id, 1, 'namespace 2 group is 1';

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
        change_item => 4
    }
);

$ua->submit_form(
    fields => {
        action_15 => 'approve',
        action_20 => 'reject'
    }
);

$ns1->discard_changes;
$ns2->discard_changes;

ok $ns1->status->is_active, 'namespace is now active';
is $ns1->group->id, 1, 'namespace 1 group is 1';
ok $ns1->last_change->change_type->is_approve, 'last change is approved';

ok $ns2->status->is_deleted, 'namespace status has not changed';
is $ns2->group->id, 1, 'namespace 2 group is 1';
ok $ns2->last_change->change_type->is_reject, 'last change is rejected';

is $ns1->last_change->affected_change->id, 15, 'affected change is correct';
is $ns2->last_change->affected_change->id, 20, 'affected change is correct';

done_testing;
