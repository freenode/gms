use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'approved_group';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get_ok("http://localhost/group/1/edit_channel_namespaces", "Edit channel namespaces page works");

$ua->content_contains("example", "namespace is in the page");

my $schema = GMS::Schema->do_connect;

my $ns = $schema->resultset('ChannelNamespace')->find({ namespace => 'example' });
ok($ns, "Check NS exists");

$ns->discard_changes;

$ua->submit_form(
    fields => {
        status_1 => 'deleted',
        edit_1   => 1,
        namespace => ''
    }
);

$ua->content_contains("Namespace updates requested successfully", "Editing namespaces works");

$ua->get_ok("http://localhost/group/1/edit_channel_namespaces", "Edit channel namespaces page works");

$ua->content_contains("At least one of the group's namespaces has a change request pending", "Pending change recognised");

$ua->content_contains("'deleted'  selected", 'Deleted option is selected, pending change status is shown');

$ua->get_ok("http://localhost/group/1/edit_channel_namespaces", "Edit channel namespaces page works");

$ua->submit_form(
    fields => {
        namespace => 'example'
    }
);

$ua->content_contains("already taken", "Trying to add a currently active namespace to your group fails");

$ua->get_ok("http://localhost/group/1/edit_channel_namespaces", "Edit channel namespaces page works");

$ua->submit_form(
    fields => {
        namespace => 'example1'
    }
);

$ua->content_contains("Namespace updates requested successfully", "Adding a new namespace succeeds");

my $schema = GMS::Schema->do_connect;

my $group = $schema->resultset('Group')->find({ group_name => 'group01' });
ok($group, "Check group exists");

is $group->channel_namespaces, 2, "Group now has two namespaces";

is $group->active_channel_namespaces, 1, "Group still has one active namespace, since requested namespace isn't active";

done_testing;
