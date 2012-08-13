#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

need_database 'basic_db';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test02',
        password => 'tester02'
    }
);

$ua->content_contains("You are now logged in as test02", "Check we can log in");

$ua->get_ok("http://localhost/userinfo", "Check contact info form");

$ua->submit_form(fields => {
        user_name => 'Contact Test',
        user_email => 'test02@example.com',
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

my $schema = GMS::Schema->do_connect;

my $account = $schema->resultset('Account')->find({ accountname => 'test02' });
ok($account, "Check account (still) exists");

my $contact = $account->contact;
ok($contact, "Check contact exists");

my $address = $contact->address;
ok($address, "Check contact has an address");

ok($contact->name eq 'Contact Test', "Check contact has the right name");
ok($contact->email eq 'test02@example.com', "Check contact has the right email");

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

done_testing;

