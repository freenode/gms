#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'basic_db';

#
# Test validation on construction
#

eval {
    $schema->resultset('Group')->create({ });
};
my $error = $@;
isa_ok $error, 'GMS::Exception::InvalidGroup';

is_deeply $error->message, [
    "Group type must be specified",
    "Group name must be provided",
    "Group URL must be provided",
], "Test group validation";

eval {
    $schema->resultset('Group')->create({
            group_type => 'informal',
            group_name => '~"#$ is not a valid group name',
            url => '~~ is not a valid group URL'
        });
};
$error = $@;
isa_ok $error, 'GMS::Exception::InvalidGroup';

is_deeply $error->message, [
    "Group name must contain only alphanumeric characters, space, underscores, hyphens and dots.",
    "Group URL contains invalid characters (valid characters are a-z, A-Z, 0-9, :_+-/)"
], "Test more group validation";

#
# Test change semantics
#

my $useraccount = $schema->resultset('Account')->search({accountname => 'test01'})->single;
ok $useraccount;
my $adminaccount = $schema->resultset('Account')->search({accountname => 'admin01'})->single;
ok $adminaccount;

my $group = $schema->resultset('Group')->create({
        account => $useraccount,
        group_type => 'informal',
        group_name => 'test',
        url => 'http://example.com'
    });

is $group->url, 'http://example.com';

my $change = $group->change($useraccount, 'request', { url => 'http://example.org' });

is $group->url, 'http://example.com', "Requested change doesn't update active state";

my $approval = $group->approve_change($change, $adminaccount);
isa_ok $approval, 'GMS::Schema::Result::GroupChange';

is $group->active_change->id, $approval->id, "Approval updates active_change";
is $group->active_change->url, 'http://example.org', "Approving a change updates group state";
is $group->url, 'http://example.org', "Approving a change updates group state";

done_testing;
