#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

# Slightly facile test that GMS::Exception behaves as expected

use_ok 'GMS::Exception';

my $exception = GMS::Exception->new("Test exception string");
isa_ok $exception, "GMS::Exception";
is $exception->message, "Test exception string";

my $exception2 = $exception->new("Test string two");
is $exception2->message, "Test string two";

throws_ok {
    die GMS::Exception::InvalidGroup->new("Invalid group test");
} qr/^Invalid group test$/;

done_testing;
