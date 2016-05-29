package GMSTest::Common;

use strict;
use warnings;

use Exporter;
our @ISA = qw/Exporter/;

our @EXPORT = qw/reset_config/;
our @EXPORT_OK  = @EXPORT;

sub import {
    my ($package, $fixtureset) = @_;

    return unless $fixtureset;

    if (-f 'gms_web_tests.conf.bak') {
       `cp gms_web_tests.conf.bak gms_web_tests.conf`;
    }

    `cp gms_web_tests.conf gms_web_tests.conf.bak`;


    `ls gms_web_tests.conf | perl bin/update_other_tables.pl $fixtureset`;
}

BEGIN {
    $ENV{GMS_WEB_CONFIG_LOCAL_SUFFIX} = 'tests';
    $ENV{GMS_WEB_CONFIG_PATH} = '.';
}

1;
