#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use lib qw(t/lib);
use GMSTest::Common 'basic_db';
use GMSTest::Database;

need_database 'basic_db';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

$ua->get_ok("http://localhost/login", "Check login page works");

$ua->content =~ /name="\_token" id="token" value="([a-z0-9]+)"/;

my $token = $1;

ok $token, 'Token is generated';

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get_ok("http://localhost/userinfo/edit");

$ua->content =~ /name="\_token" value="([a-z0-9]+)"/;
my $token2 = $1;

is $token, $token2, 'Token is the same throughout the session';

my $response = $ua->submit_form(
    fields => {
        '_token' => 'invalid'
    }
);

is $response->code, 400, 'Submitting the wrong token returns an error.';

$ua->get_ok("http://localhost/userinfo/edit");

$response = $ua->submit_form(
    fields => {
        '_token' => undef
    }
);

is $response->code, 400, 'Submitting no token returns an error.';

$ua->get_ok("http://localhost/userinfo/edit");

$response = $ua->submit_form(
    fields => {
        '_token' => $token
    }
);

is $response->code, 200, 'Submitting the correct token works';

$ua->get("http://localhost/logout");

$ua->get_ok("http://localhost/login", "Check login page works");

$ua->content =~ /name="\_token" id="token" value="([a-z0-9]+)"/;
$token2 = $1;

isnt $token, $token2, 'We get a new token now.';

done_testing;
