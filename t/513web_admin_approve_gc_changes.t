use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;
use Test::MockObject;

our $schema = need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });

my $mockAtheme = new Test::MockObject;

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

my $change_rs = $schema->resultset('GroupContactChange');
my $gc_rs = $schema->resultset('GroupContact');

my $change20 = $change_rs->find({ 'id' => 20 });
my $change21 = $change_rs->find({ 'id' => 21 });

my $id1 = $change20->contact_id . '_' . $change20->group_id;
my $id2 = $change21->contact_id . '_' . $change21->group_id;

my $gc1 = $gc_rs->find_by_id($id1);
my $gc2 = $gc_rs->find_by_id($id2);

ok $gc1->is_primary, 'gc is primary';
ok $gc2->is_primary, 'gc is primary';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->post_ok ('http://localhost/json/admin/approve_change/submit',
    {
        approve_changes => '20 21',
        change_item => 'gcc',
        action_20 => 'reject',
    }
);

$ua->post_ok ('http://localhost/json/admin/approve_change/submit',
    {
        approve_changes => '21',
        change_item => 'gcc',
        action_21 => 'approve',
    }
);

$gc1->discard_changes;
$gc2->discard_changes;

ok $gc1->last_change->change_type->is_reject, 'last change is rejected';
ok $gc1->is_primary, 'contact is still primary';

ok $gc2->last_change->change_type->is_approve, 'last change is accept';
ok !$gc2->is_primary, 'according to the change, group contact is no longer primary';


is $gc1->last_change->affected_change->id, 20, 'affected change is correct';
is $gc2->last_change->affected_change->id, 21, 'affected change is correct';

$ua->post_ok ('http://localhost/json/admin/approve_change/submit',
    {
        change_item => 'gcc',
        approve_changes => $gc1->last_change->id,
        'action_' . $gc1->last_change->id => 'approve',
    }
);

$ua->content_contains ("Can't approve a change that isn't a request", "Can't approve a change that isn't a request");

done_testing;
