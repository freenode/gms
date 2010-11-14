use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'GMS::Web' }
BEGIN { use_ok 'GMS::Web::Controller::Logout' }

ok( request('/logout')->is_redirect, 'Logout redirects when not logged in' );


