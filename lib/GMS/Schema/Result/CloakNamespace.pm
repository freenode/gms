package GMS::Schema::Result::CloakNamespace;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('cloak_namespaces');
__PACKAGE__->add_columns(qw/ group_id namespace /);

1;
