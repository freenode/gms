#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::MockModule;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

need_database 'three_groups';

# Mock atheme model so we don't use real one.
my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { die RPC::Atheme::Error->new(RPC::Atheme::Error::rpc_error, ""); });

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

$ua->content_contains("Your name can't be empty", "Errors are shown");
$ua->content_contains("Your email can't be empty", "Errors are shown");

$ua->submit_form(fields => {
        user_name => 'Contact Test',
        user_email => 'test01@example.com',
        phone => '1234',
    });

$ua->content_contains("Your contact information has been updated", "Check defining contact info");

my $contact = $account->contact;
ok($contact, "Check contact exists");

ok($contact->name eq 'Contact Test', "Check contact has the right name");
ok($contact->email eq 'test01@example.com', "Check contact has the right email");
ok($contact->active_change->phone eq '1234', "Check phone is correct");

$ua->get_ok("http://localhost/userinfo/edit", "Check contact info editing form");

$ua->submit_form(fields => {
        user_name => 'Second Contact Test',
        user_email => 'test03@example.com',
    });

$ua->content_contains("Successfully changed contact info", "Check editing contact info");

$contact->discard_changes;

ok $contact->name eq 'Second Contact Test', 'Changing info works';
ok $contact->email eq 'test03@example.com';

$ua->get_ok("http://localhost/userinfo/edit", "Check contact info editing form");

$ua->submit_form(fields => {
        user_name => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed urna risus, commodo vitae tempor vitae, sodales quis odio. Maecenas vehicula fermentum libero, sed molestie ipsum cursus in. Vivamus dignissim, velit et tristique ornare, ipsum nisi sodales amet.',
        user_email => 'test@email.com'
    });

$ua->content_contains("Your name can be up to 255 characters", "Errors are shown");

done_testing;
