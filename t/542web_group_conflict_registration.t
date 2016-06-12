#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use lib qw(t/lib);
use GMSTest::Common 'approved_group';
use GMSTest::Database;
use Test::MockModule;

# We don't want this right now.

my $mockModel = new Test::MockModule ('GMS::Web::Model::Atheme');
$mockModel->mock ('session' => sub { });

my $mock = Test::MockModule->new('GMS::Atheme::Client');
$mock->mock('new', sub { });
$mock->mock('notice_staff_chan', sub {});


need_database 'approved_group';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

my $mockGroup = new Test::MockModule('GMS::Domain::Group');
$mockGroup->mock ('new',
    sub {
        my (undef, undef, $group) = @_;
        $group;
    });

my $mockSession = new Test::MockModule ('GMS::Web::Model::Atheme');

$mockSession->mock ('session', sub {
    });

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


$ua->content_contains( "The namespace test is already taken", "Group is now taken and can't be requested again");

$ua->get_ok ("http://localhost/group", "Group page works");

$ua->content_contains ("first test", "Group is in the user's group list");

done_testing;
