use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;

# We don't want this right now.

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});


need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->post_ok ('http://localhost/json/admin/approve_namespaces/submit',
    {
        approve_item => 'clns',
        approve_namespaces => '3 4',
        action_3 => 'approve',
    }
);

$ua->post_ok ('http://localhost/json/admin/approve_namespaces/submit',
    {
        approve_item => 'clns',
        approve_namespaces => '4',
        action_4 => 'reject',
    }
);

my $schema = GMS::Schema->do_connect;

my $rs = $schema->resultset('CloakNamespace');

my $ns3 = $rs->find({ id => 3 });
my $ns4 = $rs->find({ id => 4 });

ok $ns3->status->is_active;
ok $ns4->status->is_deleted;

ok $ns3->active_change->change_type->is_admin;
ok $ns4->active_change->change_type->is_admin;


$ua->post_ok ('http://localhost/json/admin/approve_namespaces/submit',
    {
        approve_item => 'clns',
        approve_namespaces => 3,
        action_3 => 'approve'
    }
);

$ua->content_contains ("Can't approve a namespace that isn't pending approval", "Can't approve a namespace that isn't pending approval");

$ua->post_ok ('http://localhost/json/admin/approve_namespaces/submit',
    {
        approve_item => 'clns',
        approve_namespaces => 3,
        action_3 => 'reject'
    }
);

$ua->content_contains ("Can't reject a namespace not pending approval", "Can't reject a namespace not pending approval");

done_testing;
