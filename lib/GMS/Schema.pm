package GMS::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
    result_namespace => 'Result',
);


# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-03-29 22:41:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UYhUdZuOclw1lzy2VUSV1g

sub connection {
    my $self = shift;
    my $rv = $self->next::method( @_ );

    $rv->storage->sql_maker->quote_char('"');
    $rv->storage->sql_maker->name_sep('.');

    return $rv;
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
