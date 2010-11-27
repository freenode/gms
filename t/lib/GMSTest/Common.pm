package GMSTest::Common;

use strict;
use warnings;


BEGIN {
    $ENV{GMS_WEB_CONFIG_LOCAL_SUFFIX} = 'tests';
    $ENV{GMS_WEB_CONFIG_PATH} = '.';
}

1;
