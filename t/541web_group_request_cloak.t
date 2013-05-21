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

$ua->get_ok("http://localhost/group/1/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'test01',
        'cloak_namespace' => 'example',
        'cloak' => 'test'
    }
);

$ua->content_contains("Successfully requested example/test cloak for test01", "Requesting cloak wokrs");

$ua->get_ok("http://localhost/group/1/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'admin01',
        'cloak_namespace' => 'example',
        'cloak' => 'admin'
    }
);

$ua->content_contains("This user does not exist or has no contact information defined", "Can't cloak user with no contact info defined");

$ua->get_ok("http://localhost/group/1/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'invalid',
        'cloak_namespace' => 'example',
        'cloak' => 'invalid'
    }
);

$ua->content_contains("This user does not exist or has no contact information defined", "Can't cloak user that does not exist");

$ua->get_ok("http://localhost/group/1/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'test01',
        'cloak_namespace' => 'example',
        'cloak' => undef
    }
);

$ua->content_contains("The cloak cannot be empty", "Can't have empty cloak");

$ua->get_ok("http://localhost/group/1/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'test01',
        'cloak_namespace' => 'example',
        'cloak' => '!!@#'
    }
);

$ua->content_contains("The cloak contains invalid characters", "Can't have invalid cloak");

$ua->get_ok("http://localhost/group/1/cloak", "Cloak page works");

$ua->submit_form(
    fields => {
        accountname => 'test01',
        'cloak_namespace' => 'example',
        'cloak' => 'LoremipsumdolorsitametconsecteturadipiscingelitMaurisegetrutrumm'
    }
);

$ua->content_contains("The cloak is too long", "Can't have invalid cloak");

done_testing;
