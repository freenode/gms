use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockObject;

use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);

our ($file, $content);

need_database 'pending_changes';

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

my $schema = GMS::Schema->do_connect;

my $group = $schema->resultset('Group')->find({ group_name => 'group06' });
ok($group, "Check group exists");

$file = $group->verify_url;
$content = $group->verify_token;

{ # for the tiny httpd started to test web verification

    sub handle_request {
        my ($self, $cgi) = @_;

        my $path = $cgi->path_info;

        if ($file =~ /$path/) {
            print $content . "\n";
        }

        exit;
    }
}

__PACKAGE__->new(1337)->background;

$ua->get_ok ("http://localhost/group/6/verify", "Verification page works");
$ua->submit_form;

$ua->content_contains ("successfully verified", "Web verification worked");

my $mock = Test::MockObject->new;

$mock->fake_module (
    'Socket',
    'inet_ntoa' => sub { '5.9.244.117' },
    'inet_aton' => sub { 1 }, # since we're also faking inet_ntoa a nonzero value will suffice.
);

$ua->get_ok ("http://localhost/group/7/verify", "Verification page works");
$ua->submit_form;

$ua->content_contains ("successfully verified", "Web verification worked");

done_testing;
