use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'new_db';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

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

$ua->post_ok ('http://localhost/json/admin/search_group_name',
    {
        name => 'group'
    }
);

$ua->content_contains('group0', 'json output works');

$ua->post_ok ('http://localhost/json/admin/search_account_name',
    {
        name => 'account'
    }
);

$ua->content_contains('account48', 'json output works');

$ua->post_ok ('http://localhost/json/admin/search_full_name',
    {
        name => 'name'
    }
);

$ua->content_contains('Name2', 'json output works');

$ua->post_ok ('http://localhost/json/admin/search_ns_name',
    {
        name => 'group'
    }
);

$ua->content_contains('group15', 'json output works');

done_testing;
