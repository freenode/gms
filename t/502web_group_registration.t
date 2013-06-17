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

$ua->get_ok("http://localhost/group/new", "Check new group page works");

$ua->submit_form(
    fields => {
        group_type => 'informal',
        group_name => 'Group test',
        group_url  => 'http://www.example.com/',
        channel_namespace => 'example',
        has_address => 'n'
    }
);

$ua->content_contains ("This group name is already taken.", "Can't register a group that already exists");

$ua->get_ok("http://localhost/group/new", "Check new group page works");

$ua->submit_form(
    fields => {
        group_type => 'corporation',
        group_name => 'Another test',
        group_url  => 'http://www.example.com/',
        channel_namespace => 'example2',
        has_address => 'y',
        address_one => 'Addr 1',
        city => 'City',
        state => 'state',
        country => 'Country',
        postcode => '001',
        phone => '01234567'
    }
);

$ua->content_contains ("successfully added", "Submitting a group with an address works");

$group = $schema->resultset('Group')->find({ group_name => 'Another test' });
ok($group, "Check group exists");

is $group->address->address_one, 'Addr 1', 'Address is correct';
is $group->address->city, 'City', 'Address is correct';
is $group->address->state, 'state', 'Address is correct';
is $group->address->country, 'Country', 'Address is correct';
is $group->address->code, '001', 'Address is correct';
is $group->address->phone, '01234567', 'Address is correct';

$ua->get_ok("http://localhost/group/new", "Check new group page works");

$ua->submit_form(
    fields => {
        group_type => 'corporation',
        group_name => 'This should fail',
        group_url  => 'http://www.example.com/',
        channel_namespace => 'example10',
        has_address => 'n',
    }
);

$ua->content_contains ("Corporation, education, NFP and government groups must have an address.", "Errors are shown");

$ua->submit_form(
    fields => {
        group_type => 'corporation',
        group_name => 'This should fail',
        group_url  => 'http://www.example.com/',
        channel_namespace => 'example10',
        has_address => 'y',
    }
);

$ua->content_contains ("If the group has its own address, then a valid address must be specified.", "Errors are shown");

done_testing;
