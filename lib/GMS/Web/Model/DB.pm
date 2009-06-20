package GMS::Web::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'GMS::Schema',
    AutoCommit => 1
);
