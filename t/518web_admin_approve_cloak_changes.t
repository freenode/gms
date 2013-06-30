use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;
use Test::MockObject;

our $schema = need_database 'new_db';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockAtheme = new Test::MockObject;

$mockAtheme->mock ( 'command', sub {
    shift @_ for 1 .. 2;

    my ($command, $param1, $param2) = ( @_ );

    if ( $command eq 'metadata' ) {
        if ($param2 eq 'private:mark:reason') {
            return "test mark reason";
        } elsif ($param2 eq 'private:mark:setter') {
            return "admin";
        } elsif ($param2 eq 'private:mark:timestamp') {
            return "1362561337";
        }
    } elsif ( $command eq 'accountname' ) {
        my $account = $schema->resultset('Account')->find ({
                id => $param1
            });
        return $account->accountname;
    } elsif ( $command eq 'uid' ) {
        my $account = $schema->resultset('Account')->find ({
                accountname => $param1
            });
        return $account->id;
    }
});

$mockAtheme->mock ( 'service', sub { 'GMSServ' } );

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

my $mockAccount = new Test::MockModule ('GMS::Schema::Result::Account');
$mockAccount->mock ('dropped' => sub { 0; } );

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $change_rs = $schema->resultset('CloakChange');

my $change5 = $change_rs->find({ 'id' => 5 });
my $change10 = $change_rs->find({ 'id' => 10 });

ok !$change5->active_change->status->is_approved, 'change has not been approved yet.';
ok !$change5->active_change->status->is_rejected, 'change has not been rejected yet.';

ok !$change10->active_change->status->is_approved, 'change has not been approved yet.';
ok !$change10->active_change->status->is_rejected, 'change has not been rejected yet.';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin", "Check we can log in");

$ua->post_ok('http://localhost/json/admin/approve_cloak/submit',
    {
        approve_changes => '5 10',
        action_5 => 'approve'
    }
);

$change5->discard_changes;

ok $change5->active_change->status->is_applied, 'change has been applid';

$ua->post_ok('http://localhost/json/admin/approve_cloak/submit',
    {
        approve_changes => '5 10',
        action_10 => 'reject'
    }
);

$change10->discard_changes;

ok $change10->active_change->status->is_rejected, 'change has been rejected';

done_testing;
