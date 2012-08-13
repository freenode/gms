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
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

$ua->get_ok("http://localhost/group/new", "Check new group page works");

$ua->content_contains("Group Registration Form", "Check new group page works");

$ua->submit_form(
    fields => {
        group_type => 'informal',
        group_name => 'Group test',
        group_url  => 'http://www.example.com/',
        channel_namespace => 'example',
        has_address => 'n'
    }
);

$ua->content_contains ("successfully added", "Submitting a new group works");

my $schema = GMS::Schema->do_connect;

my $group = $schema->resultset('Group')->find({ group_name => 'Group test' });
ok($group, "Check group exists");

is $group->group_name, 'Group test', 'Group name is corret';
ok $group->group_type->is_informal, 'Type is correct';
is $group->url, 'http://www.example.com/', 'URL is correct';
ok $group->status->is_pending_web, 'Group status is correct';

is $group->group_contacts->count, 1, 'Submitted group has one contact';

is $group->active_group_contacts->count, 0, 'Submitted group has no active contacts';

is $group->channel_namespaces->count, 1, 'Submitted group has one channel namespace';
is $group->channel_namespaces->single->namespace, 'example', 'Namespace is correct';

is $group->active_channel_namespaces->count, 0, 'Submitted group has no active channel namespace';

$ua->get_ok ("http://localhost/group", "Group page works");

$ua->content_contains ("Group test", "Group is in the user's group list");

done_testing;
