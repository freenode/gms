#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

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

$ua->get_ok("http://localhost/group/new", "Check new group page works");

$ua->submit_form(
    fields => {
        group_type => 'informal',
        group_name => 'first test',
        group_url  => 'http://www.example.com/',
        channel_namespace => 'test',
        has_address => 'n'
    }
);

$ua->content_contains( "successfully added", "We can revive a deleted namespace" );

$ua->get_ok("http://localhost/group/new", "Check new group page works");

$ua->submit_form(
    fields => {
        group_type => 'informal',
        group_name => 'another test',
        group_url  => 'http://www.example.com/',
        channel_namespace => 'test',
        has_address => 'n'
    }
);

$ua->content_contains( "Another group has requested the test namespace. Are you sure you want to create a conflicting request?", "We get a warning when requesting another group's namespace" );

$ua->get_ok("http://localhost/group/new", "Check new group page works");

$ua->submit_form(
    fields => {
        group_type => 'informal',
        group_name => 'third test',
        group_url  => 'http://www.example.com/',
        channel_namespace => 'test',
        has_address => 'n',
        do_confirm => 1
    }
);

$ua->content_contains( "successfully added", "We can create a conflicting request if we confirm we want to" );

$ua->get_ok ("http://localhost/group", "Group page works");

$ua->content_contains ("first test", "Group is in the user's group list");
$ua->content_contains ("third test", "Group is in the user's group list");

done_testing;
