package GMS::Schema;
use strict;
use warnings;
use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces();

sub connection {
    my $self = shift;
    my $rv = $self->next::method( @_ );

    $rv->storage->sql_maker->quote_char('"');
    $rv->storage->sql_maker->name_sep('.');

    return $rv;
}

1;
