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


use Data::Dumper;

eval {
    my @arr = ('Error1', 'Error2');
    die ( GMS::Exception->new(  \@arr ) ) ;
};

my $error = $@;
ok $error;

is_deeply $error->errors, [ 'Error1', 'Error2' ], 'Dying with an array works';
is_deeply $error->message, [ 'Error1', 'Error2' ], '$error->message works';
is_deeply "$error", "Error1\nError2", "Stringifying works";

done_testing;
