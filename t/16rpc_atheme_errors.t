#!/usr/bin/env perl

use strict;
use warnings;
use Test::Most;
use Test::MockModule;
use Test::MockObject;

use lib qw(t/lib);
use GMSTest::Common;
use GMS::Config;

my $config = GMS::Config->atheme;
my ($host, $port, $user, $pass) = @{$config}{qw/hostname port master_account master_password/};

use_ok 'RPC::Atheme::Session';

my $mockClient = new Test::MockModule('RPC::XML::Client');

$mockClient->mock ('new', sub {
        $RPC::XML::ERROR = "Test error";
        undef;
    });

throws_ok {
    RPC::Atheme::Session->new( $host, $port );
} qr /Test error/, "XML::RPC Errors are thrown back";

my $mockObject = Test::MockObject->new();

$mockObject->mock ('simple_request', sub {
        $RPC::XML::ERROR = "Test error";
        undef;
    });

$mockClient->mock ('new', sub {
        $mockObject;
    });

my $session = RPC::Atheme::Session->new( $host, $port );
ok $session;

throws_ok {
    $session->login;
} qr/Test error/, "XML::RPC errors are thrown back";

$mockObject->mock ('simple_request', sub {
        1;
    });
$mockClient->mock ('new', sub {
        $mockObject;
    });

ok $session->login;

$mockObject->mock ('simple_request', sub {
        $RPC::XML::ERROR = "Test error";
        undef;
    });

$mockClient->mock ('new', sub {
        $mockObject;
    });

throws_ok {
    $session->command;
} qr /Test error/, "XML::RPC errors are thrown back";


my $mockAtheme = new Test::MockModule('RPC::Atheme::Session');
$mockAtheme->mock ('do_command', sub {
        die "Test Error";
    });

throws_ok {
    $session->command;
} qr /Test Error/, "Other errors are also thrown back";

done_testing;
