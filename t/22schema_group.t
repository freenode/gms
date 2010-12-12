#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'basic_db';

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


done_testing;
