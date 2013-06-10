#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;
use Test::MockObject;

use lib qw(t/lib);
use GMSTest::Common;
use GMS::Atheme::Client;
use String::Random qw/random_string/;

my $mock = Test::MockObject->new;

$mock->mock ( 'model' => sub { $mock } );
$mock->mock ( 'session' => sub { $mock });
$mock->mock ( 'service' => sub { 'GMSServ' } );
$mock->mock ( 'command', sub {
        shift @_; #we don't need the first element, which is a Test::MockObject
        return @_;
    });

my $cloak = "test/" . random_string("cccccccc");
my $client = GMS::Atheme::Client->new ( $mock );

my @result = $client->cloak ( 'AAAAAAAAP', $cloak);

is_deeply ( \@result, [
   "GMSServ",
   "cloak",
   "AAAAAAAAP",
   $cloak
], "Test setting cloaks");

done_testing;
