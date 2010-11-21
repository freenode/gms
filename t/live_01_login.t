#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use lib qw(t/lib);

BEGIN {
    $ENV{GMS_WEB_CONFIG_LOCAL_SUFFIX} = 'tests';
    $ENV{GMS_WEB_CONFIG_PATH} = '.';
}

use GMS::Schema;
use DBIx::Class::Fixtures;

my $schema = GMS::Schema->do_connect();
$schema->deploy({ add_drop_table => 1 });
my $fixtures = DBIx::Class::Fixtures->new({ config_dir => 't/etc' });
$fixtures->populate({
    directory => 't/etc/basic_db',
    schema => $schema,
    no_deploy => 1
});

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

done_testing;
