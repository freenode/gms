use lib qw(t/lib);
use GMSTest::Common 'approved_group';
use GMSTest::Database;
use Test::More;
use Test::More;
use Test::MockObject;
use Test::MockModule;

# We don't want this right now.

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('notice_staff_chan', sub {});


our $schema = need_database 'approved_group';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockGroup = new Test::MockModule('GMS::Domain::Group');
$mockGroup->mock ('new',
    sub {
        my (undef, undef, $group) = @_;
        $group;
    });

my $mockSession = new Test::MockModule ('GMS::Web::Model::Atheme');

$mockSession->mock ('session', sub {
    });

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });

$mockAccounts->mock ('find_by_name', sub {
        my ( $self, $name  ) = @_;

        return $schema->resultset('Account')->find ({ accountname => $name });
    });

my $mockAtheme = new Test::MockObject;
$mockAtheme->mock ( 'user' => sub { $mock } );
$mockAtheme->mock ( 'model' => sub { $mock } );
$mockAtheme->mock ( 'session' => sub { $mock });
$mockAtheme->mock ( 'service' => sub { 'GMSServ' } );
$mockAtheme->mock ( 'command', sub {
        1;
    });
$mockAtheme->mock ('login', sub {
        1;
    });
$mockAtheme->mock ('info', sub {
        "Information on admin01 (account admin01):
        Registered : Nov 20 22:10:17 2014 (5w 6d 19h ago)
        Last seen  : (about 5 weeks ago)
        User seen  : (about 0 weeks ago)
        Flags      : HideMail, Private
        *** End of Info ***";
    });

$mockAtheme->mock('chanexists', sub { 1; });
$mockAtheme->mock('chanregistered', sub { 0; });
$mockAtheme->mock('notice_staff_chan', sub { } );

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

my $mockClient = new Test::MockModule ('GMS::Atheme::Client');
$mockClient->mock ('new' => sub { $mockAtheme });

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

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#example-test',
        action => 1,
        target_gc => '1',
    }
);


$ua->content_contains ("Successfully requested the channel take over", "Transfer works");

$ua->get_ok("http://localhost/group/1/listchans");

$ua->content_contains('#example-test', 'Pending requests are shown');

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        action => 1,
        target_gc => '1'
    }
);

$ua->content_contains ("This namespace does not belong in your Group's namespaces.", "Errors are shown");

$mockAtheme->mock('chanregistered', sub { 1; });

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#example-test',
        action => 2,
        target_gc => '1',
    }
);

$ua->content_contains ("Successfully requested the channel drop", "Drop works");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        action => 2,
        target_gc => '1'
    }
);

$ua->content_contains ("This namespace does not belong in your Group's namespaces.", "Errors are shown");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#example',
        action => 1,
        target => 'admin01'
    }
);

$ua->content_contains ("Please confirm that this is the user that you think it is", "Users are asked to confirm when transferring to an arbitary user");

$ua->submit_form(
    fields => {
        channel => '#example',
        action => 1,
        target => 'admin01',
        confirm => 1
    }
);

$ua->content_contains ("Successfully requested the channel take over", "Transfer works");

my $group = $schema->resultset('Group')->find({ group_name => 'group01' });
my $admin = $schema->resultset('Account')->find({ accountname => 'admin01' });

$group->change( $admin, 'workflow_change', { status => 'pending_staff' });

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");
$ua->content_contains("The group is not active", "Can't take over on inactive group");

done_testing;
