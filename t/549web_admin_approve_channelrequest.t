use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;
use Test::MockObject;
use RPC::Atheme::Error;

our $schema = need_database 'new_db';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $user = $schema->resultset('Account')->find ({ 'accountname' => 'account0' });
my $admin = $schema->resultset('Account')->find({ 'accountname' => 'admin' });
my $group = $schema->resultset('Group')->find({ 'group_name' => 'group020' });

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });

my $mockAtheme = new Test::MockObject;

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

my $mockClient = new Test::MockModule('GMS::Atheme::Client');

$mockClient->mock ('drop', sub {
});

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin", "Check we can log in");

my $req = $schema->resultset('ChannelRequest')->create({
        requestor    => $user->contact,
        request_type => 'drop',
        channel      => '#group0',
        namespace    => 'group0',
        group        => $group,
        changed_by   => $user,
    });

$ua->get_ok("http://localhost/admin/approve_channel_requests", "Channel request approval page works");

$ua->content_contains ('account0', 'Request exists');
$ua->content_contains ('drop', 'Request exists');
$ua->content_contains ('#group0', 'Request exists');

$ua->submit_form(
    fields => {
        action_51 => 'hold',
    }
);

$ua->get_ok("http://localhost/admin/approve_channel_requests", "Channel request approval page works");

$ua->content_contains ('account0', 'Request is still there');
$ua->content_contains ('drop', 'Request is still there');
$ua->content_contains ('#group0', 'Request is still there');

$ua->submit_form(
    fields => {
        action_51 => 'reject',
    }
);

$req->discard_changes;
ok $req->active_change->status->is_rejected, 'request is now rejected';
ok $req->change ($admin, { status => 'pending_staff' });

$ua->get_ok("http://localhost/admin/approve_channel_requests", "Channel request approval page works");

$ua->submit_form(
    fields => {
        action_51 => 'approve',
    }
);

$req->discard_changes;
ok $req->active_change->status->is_applied, 'request is now applied';
ok $req->change ($admin, { status => 'pending_staff' });

$mockClient->mock ('drop', sub {
        die RPC::Atheme::Error->new (1, 'Test error');
    });

$ua->get_ok("http://localhost/admin/approve_channel_requests", "Channel request approval page works");

$ua->submit_form(
    fields => {
        action_51 => 'approve',
    }
);

$req->discard_changes;
ok $req->active_change->status->is_error, 'request status is now error';
is $req->active_change->change_freetext, 'Test error (fault_needmoreparams)', 'Error message is shown';

$ua->get_ok("http://localhost/admin/approve_channel_requests", "Channel request approval page works");

$ua->submit_form(
    fields => {
        action_51 => 'apply',
    }
);

$req->discard_changes;
ok $req->active_change->status->is_applied, 'request status is now applied';

done_testing;
