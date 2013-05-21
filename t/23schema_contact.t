#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'basic_db';

my $account = $schema->resultset('Account')->find({ accountname => 'test01' });
isa_ok $account, 'GMS::Schema::Result::Account';

my $adminaccount = $schema->resultset('Account')->find({ accountname => 'admin01' });
isa_ok $adminaccount, 'GMS::Schema::Result::Account';

my $contact = $account->contact;
isa_ok $contact, 'GMS::Schema::Result::Contact';

my $original_name = $contact->name;
my $original_email = $contact->email;

my $new_name = 'Test Contact Changed';
my $new_email = 'changed@example.com';

is $schema->resultset('ContactChange')->active_requests->count, 0;

my $change = $contact->change($account, 'request', { 'name' => $new_name,  'email' => $new_email });
isa_ok $change, 'GMS::Schema::Result::ContactChange';

is $schema->resultset('ContactChange')->active_requests->count, 1, 'Pending requests increase on request';

is $contact->name, $original_name, "Requested change doesn't update active state";
is $contact->email, $original_email, "Requested change doesn't update active state";

$change->approve($adminaccount, "test");

is $schema->resultset('ContactChange')->active_requests->count, 0, 'Pending requests decrease on approval';

$contact->discard_changes;

is $contact->active_change->name, $new_name, "Approving change updates active state";
is $contact->active_change->email, $new_email, "Approving change updates active state";

$account = $schema->resultset('Account')->find({ accountname => 'test02' });
isa_ok $account, 'GMS::Schema::Result::Account';

my $address = $schema->resultset('Address')->create({
    address_one => 'Test address',
    city => 'Test city',
    state => 'Test state',
    code => 'Test001',
    country => 'Test country',
    phone => '0123456789'
});
isa_ok $address, 'GMS::Schema::Result::Address';

$contact = $schema->resultset('Contact')->create({
    account_id => $account->id,
    name => 'Test name',
    email => 'test@example.com',
    address => $address->id
});

ok $contact, 'We can create a new contact';
is $contact->address->id, $address->id, 'The address is correct';

ok $contact->change ( $adminaccount, 'admin', { } );

is $contact->name, 'Test name', 'Details we do not change stay the same';
is $contact->email, 'test@example.com', 'Details we do not change stay the same';
is $contact->address->id, $address->id, 'Details we do not change stay the same';

$address = $schema->resultset('Address')->create({
    address_one => 'Test address 2',
    city => 'Test city 2',
    state => 'Test state 2',
    code => 'Test002',
    country => 'Test country 2',
    phone => '0123456789'
});
isa_ok $address, 'GMS::Schema::Result::Address';

$change = $contact->change ( $adminaccount, 'admin', { 'address' => $address->id } );

ok $change;
is $contact->address->id, $address->id, 'Changing address works';

throws_ok { $change->approve ($adminaccount) } qr/Can't approve a change that isn't a request/, "Can't approve a change that isn't a request";
throws_ok { $change->reject ($adminaccount) } qr/Can't reject a change that isn't a request/, "Can't reject a change that isn't a request";

$change =$contact->change ( $account, 'request', { 'name' => 'New name' } );

ok $change;
is $contact->name, 'Test name', 'Unapproved requests do not take effect';

throws_ok { $change->approve } qr/Need an account to approve a change/, "Can't approve a change without an account";
throws_ok { $change->reject } qr/Need an account to reject a change/, "Can't approve a change without an account";

$change = $contact->change ( $account, 'request', { 'email' => 'new@email.com' } );

ok $change;
is $contact->email, 'test@example.com', 'Unapproved requests do not take effect';

ok $change->approve ($adminaccount);
$contact->discard_changes;

is $contact->name, 'New name', 'Both changes have been applied by approving one of them - changes inherit previous changes';
is $contact->email, 'new@email.com', 'Both changes have been applied by approving one of them - changes inherit previous changes';

$change = $contact->change ( $account, 'request', { 'email' => 'another@email.com' } );
ok $change;

ok $change->reject ($adminaccount), 'Rejecting changes works';
is $contact->email, 'new@email.com', 'Rejected changes do not take effect';

eval {
    $schema->resultset('Contact')->create({ });
};

my $error = $@;
ok $error;

is_deeply $error->message, [
    "Your name can't be empty.",
    "Your email can't be empty.",
    "Your address can't be empty."
], 'Test field validation';

eval {
    $schema->resultset('Contact')->create({
        account_id => $account->id,
        name => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed urna risus, commodo vitae tempor vitae, sodales quis odio. Maecenas vehicula fermentum libero, sed molestie ipsum cursus in. Vivamus dignissim, velit et tristique ornare, ipsum nisi sodales amet.',
        email => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed urna risus, commodo vitae tempor vitae, sodales quis odio. Maecenas vehicula fermentum libero, sed molestie ipsum cursus in. Vivamus dignissim, velit et tristique ornare, ipsum nisi sodales amet.',
    });
};

$error = $@;
ok $error;

is_deeply $error->message, [
    "Your name can be up to 255 characters.",
    "Your email can be up to 255 characters.",
    "Your address can't be empty."
], 'Test field validation';

eval {
    $schema->resultset('ContactChange')->new ({ });
};

$error = $@;
ok $error;

is_deeply $error->message, [
    "Your name can't be empty.",
    "Your email can't be empty.",
    "Your address can't be empty."
], "We can't create a ContactChange without the necessary arguments";

done_testing;
