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
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->get_ok("http://localhost/admin/1/edit_channel_namespaces", "Edit channel namespaces page works");

$ua->content_contains("example", "namespace is in the page");

my $schema = GMS::Schema->do_connect;

my $ns = $schema->resultset('ChannelNamespace')->find({ namespace => 'example' });
ok($ns, "Check NS exists");

$ua->submit_form(
    fields => {
        status_1 => 'deleted',
        edit_1   => 1,
        namespace => ''
    }
);

$ua->content_contains("Namespaces updated successfully", "Editing namespaces works");

$ns->discard_changes;

is $ns->status->is_deleted, 1, 'Admin changes are applied.';

$ua->get_ok("http://localhost/admin/1/edit_channel_namespaces", "Edit channel namespaces page works");

$ua->content_contains("'deleted'  selected", 'Deleted option is selected, pending change status is shown');

$ua->get_ok("http://localhost/admin/1/edit_channel_namespaces", "Edit channel namespaces page works");

my $group = $schema->resultset('Group')->find({ group_name => 'group01' });
ok($group, "Check group exists");

is $group->channel_namespaces, 2, "Group initially has 2 namespaces";
$ua->submit_form(
    fields => {
        namespace => 'example'
    }
);

$ua->content_contains("Namespaces updated successfully", "We can revive a deleted namespace");

$ua->get_ok("http://localhost/admin/1/edit_channel_namespaces", "Edit channel namespaces page works");

$ua->submit_form(
    fields => {
        namespace => 'example1'
    }
);

$ua->content_contains("Namespaces updated successfully", "Adding a new namespace succeeds");

$ua->get_ok("http://localhost/admin/1/edit_channel_namespaces", "Edit channel namespaces page works");

$ua->submit_form(
    fields => {
        namespace => 'example1'
    }
);

$ua->content_contains("already taken", "Trying to add a currently active namespace to your group fails");

is $group->channel_namespaces, 3, "Group now has 3 namespaces";
is $group->active_channel_namespaces, 2, "Group has 2 active namespace";

$ua->get_ok("http://localhost/admin/1/edit_channel_namespaces", "Edit channel namespaces page works");

done_testing;
