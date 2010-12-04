package GMS::Web::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'GMS::Schema',
    AutoCommit => 1
);

=head1 NAME

GMS::Web::Model::DB

=head1 DESCRIPTION

Catalyst model for GMS::Web wrapping around L<GMS::Schema>.

=cut
