#!/usr/bin/perl

use Carp::Always;

use strict;
use warnings;
use Test::More;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

need_database 'three_groups';

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

$ua->get_ok("http://localhost/userinfo", "Check contact info form");

my $schema = GMS::Schema->do_connect;

my $account = $schema->resultset('Account')->find({ accountname => 'test01' });
ok($account, "Check account exists");

ok !$account->contact, "Account doesn't yet have contact info";

$ua->submit_form;

$ua->content_contains("Address 1 is missing", "Errors are shown");

$ua->submit_form(fields => {
        address_one => '2 Test Road',
        address_two => '',
        city => 'Testville',
        state => '',
        postcode => '12345',
        country => 'Testland',
        phone_one => '123 4567890',
        phone_two => '',
    });

$ua->content_contains("Your name can't be empty", "Errors are shown");
$ua->content_contains("Your email can't be empty", "Errors are shown");

$ua->submit_form(fields => {
        user_name => 'Contact Test',
        user_email => 'test01@example.com',
        address_one => '2 Test Road',
        address_two => '',
        city => 'Testville',
        state => '',
        postcode => '12345',
        country => 'Testland',
        phone_one => '123 4567890',
        phone_two => '',
    });

$ua->content_contains("Your contact information has been updated", "Check defining contact info");

my $contact = $account->contact;
ok($contact, "Check contact exists");

my $address = $contact->address;
ok($address, "Check contact has an address");

ok($contact->name eq 'Contact Test', "Check contact has the right name");
ok($contact->email eq 'test01@example.com', "Check contact has the right email");

ok($address->address_one eq '2 Test Road', "Check address is correct");
ok($address->address_two eq '', "Check address is correct");
ok($address->city eq 'Testville', "Check address is correct");
ok($address->state eq '', "Check address is correct");
ok($address->code eq '12345', "Check address is correct");
ok($address->country eq 'Testland', "Check address is correct");
ok($address->phone eq '123 4567890', "Check address is correct");
ok($address->phone2 eq '', "Check address is correct");

$ua->get_ok("http://localhost/userinfo/edit", "Check contact info editing form");

$ua->submit_form(fields => {
        user_name => 'Second Contact Test',
        user_email => 'test03@example.com',
    });

$ua->content_contains("Successfully submitted the change request", "Check editing contact info");

$ua->get_ok("http://localhost/userinfo/edit", "Check contact info editing form");

$ua->content_contains("There is already a change request pending", "Perevious requests to edit are considered");

$ua->content_contains("Second Contact Test", "The input fields have the new information for editing");

$ua->content_contains('test03@example.com', "The input fields have the new information for editing");

$ua->get_ok("http://localhost/userinfo/edit", "Check contact info editing form");

$ua->submit_form(fields => {
        address_one => 'Another test address',
        address_two => '',
        city => 'City',
        state => '',
        postcode => '001',
        country => 'Country',
        phone_one => '123 4567890',
        phone_two => '',
        update_address => 'n'
    });

# We want the last change, not the active change, since it's a request.
$address = $contact->last_change->address;

ok($address->address_one eq '2 Test Road', "Address hasn't changed since we didn't provide update_address => y");
ok($address->address_two eq '', "Address hasn't changed since we didn't provide update_address => y");
ok($address->city eq 'Testville',  "Address hasn't changed since we didn't provide update_address => y");
ok($address->state eq '',  "Address hasn't changed since we didn't provide update_address => y");
ok($address->code eq '12345',  "Address hasn't changed since we didn't provide update_address => y");
ok($address->country eq 'Testland',  "Address hasn't changed since we didn't provide update_address => y");
ok($address->phone eq '123 4567890',  "Address hasn't changed since we didn't provide update_address => y");
ok($address->phone2 eq '',  "Address hasn't changed since we didn't provide update_address => y");

$ua->get_ok("http://localhost/userinfo/edit", "Check contact info editing form");

$ua->submit_form(fields => {
        address_one => 'Another test address',
        address_two => '',
        city => 'City',
        state => '',
        postcode => '001',
        country => 'Country',
        phone_one => '123 4567890',
        phone_two => '',
        update_address => 'y'
    });

$address = $contact->last_change->address;

ok($address->address_one eq 'Another test address', "The change request has now been recorded");
ok($address->city eq 'City', "The change request has now been recorded");
ok($address->code eq '001', "The change request has now been recorded");
ok($address->country eq 'Country', "The change request has now been recorded");

$ua->get_ok("http://localhost/userinfo/edit", "Check contact info editing form");

$ua->submit_form(fields => {
        update_address => 'y',
        address_one => undef
    });

$ua->content_contains("Address 1 is missing", "Errors are shown");

$ua->submit_form(fields => {
        address_one => 'Another test address',
        address_two => '',
        city => 'City',
        state => '',
        postcode => '001',
        country => 'Country',
        phone_one => '123 4567890',
        phone_two => '',
        update_address => 'y',

        user_name => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed urna risus, commodo vitae tempor vitae, sodales quis odio. Maecenas vehicula fermentum libero, sed molestie ipsum cursus in. Vivamus dignissim, velit et tristique ornare, ipsum nisi sodales amet.',
        user_email => 'test@email.com'
    });

$ua->content_contains("Your name can be up to 255 characters", "Errors are shown");

done_testing;
