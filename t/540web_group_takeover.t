use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;

need_database 'approved_group';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $module = new Test::MockModule("RPC::Atheme::Session");

$module->mock ( 'login', sub {
        return 1;
    });
$module->mock ( 'command', sub {
        return 1;
    });

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
        channel_namespace => 'example',
        action => 1,
        group_contact => 1,
    }
);


$ua->content_contains ("Successfully transferred the channel to test01", "Transfer works");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        channel_namespace => 'example',
        action => 1,
        group_contact => 1
    }
);

$ua->content_contains ("This channel does not belong in that namespace", "Errors are shown");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        channel_namespace => 'another',
        action => 1,
        group_contact => 1
    }
);

$ua->content_contains ("This namespace does not belong in your Group's namespaces.", "Errors are shown");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#example-test',
        channel_namespace => 'example',
        action => 2,
    }
);

$ua->content_contains ("Successfully dropped the channel", "Drop works");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        channel_namespace => 'example',
        action => 2,
        group_contact => 'test01'
    }
);

$ua->content_contains ("This channel does not belong in that namespace", "Errors are shown");

$ua->get_ok("http://localhost/group/1/take_over", "Take over page works");

$ua->submit_form(
    fields => {
        channel => '#another-thing',
        channel_namespace => 'another',
        action => 2,
        group_contact => 'test01'
    }
);

$ua->content_contains ("This namespace does not belong in your Group's namespaces.", "Errors are shown");

done_testing;
