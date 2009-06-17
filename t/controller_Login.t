use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'GMS::Web' }
BEGIN { use_ok 'GMS::Web::Controller::Login' }

ok( request('/login')->is_success, 'Request should succeed' );


