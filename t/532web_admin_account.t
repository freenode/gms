use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;
use Test::MockModule;
use Test::MockObject;

our $schema = need_database 'approved_group';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockAccounts = new Test::MockModule ('GMS::Domain::Accounts');

$mockAccounts->mock ('find_by_uid', sub {
        my ( $self, $uid ) = @_;

        return $schema->resultset('Account')->find ({ id => $uid });
    });

my $mockAtheme = new Test::MockObject;

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { $mockAtheme });

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

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/view", "View account page works");

$ua->content_contains("test01's contact information", "Account viewing page works");

$ua->text_like (qr#Account name.*test01#, "Account viewing page works");
$ua->text_like (qr#Real name.*test01#, "Account viewing page works");
$ua->text_like (qr#E-mail Address.*test01\@example.com#, "Account viewing page works");

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/edit", "Check contact info editing form");

$ua->submit_form(fields => {
        user_name => 'Second Contact Test',
        user_email => 'test03@example.com',
    });

$ua->content_contains("Successfully edited the user's contact information", "Check editing contact info");

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/edit", "Check contact info editing form");

$ua->content_contains("Second Contact Test", "The input fields have the new information for editing");
$ua->content_contains('test03@example.com', "The input fields have the new information for editing");

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/view", "View account page works");

$ua->content_contains("Second Contact Test", "Info has changed");
$ua->content_contains('test03@example.com', "Info has changed");

my $schema = GMS::Schema->do_connect;

my $account = $schema->resultset('Account')->find({ 'accountname' => 'test01' });
ok $account;
isa_ok $account, 'GMS::Schema::Result::Account';

is $account->contact->name, 'Second Contact Test', 'Admin changes are applied';
is $account->contact->email, 'test03@example.com', 'Admin changes are applied';

ok $account->contact->change ( $account, 'request', { 'name' => 'Another Test' });

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/edit", "Check contact info editing form");

$ua->content_contains ("already a change request pending", "Pending request is recognised");
$ua->content_contains ("Another Test", "Pending change is recognised");

$ua->submit_form(fields => {
        phone => 9876543210
    });

$account->contact->discard_changes;

is $account->contact->phone, 9876543210, 'Updating contact info works';

$ua->get_ok("http://localhost/admin/account/AAAAAAAAP/edit", "Check contact info editing form");

$ua->get_ok("http://localhost/admin/account/AAAAAAAAS/edit", "Check contact info editing form");

my $account = $schema->resultset('Account')->find({ 'accountname' => 'admin01' });
ok $account;
isa_ok $account, 'GMS::Schema::Result::Account';

ok !$account->contact, 'No contact information yet.';

$ua->submit_form(fields => {
    phone => 9876543210
});

$ua->content_contains(
    "Your name can't be empty",
    "Contact information is required when creating a new contact"
);

$ua->submit_form(fields => {
        user_name => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed urna risus, commodo vitae tempor vitae, sodales quis odio. Maecenas vehicula fermentum libero, sed molestie ipsum cursus in. Vivamus dignissim, velit et tristique ornare, ipsum nisi sodales amet.',
        user_email => 'test@email.com'
    });

$ua->content_contains("Your name can be up to 255 characters", "Errors are shown");

$ua->submit_form(fields => {
    user_name  => 'Test Name',
    user_email => 'test@email.com',
    phone      => '12345678910'
});

ok $account->contact, "The account now has contact info";

is $account->contact->name, 'Test Name', 'Updating contact info works';
is $account->contact->email, 'test@email.com', 'Updating contact info works';
is $account->contact->phone, '12345678910', 'Updating contact info works';

done_testing;
