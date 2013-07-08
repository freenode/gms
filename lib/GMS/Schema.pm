use utf8;
package GMS::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-07 12:07:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DqFS3cQmQC0J5TAqos99DA

=head1 NAME

GMS::Schema

=head1 DESCRIPTION

A L<DBIx::Class> schema for the GMS database.

=head1 METHODS

=head2 connection

Overloads the DBIx::Class::Schema connection() method, and changes the sql_maker
settings to match what Postgres needs.

=cut

sub connection {
    my $self = shift;
    my $rv = $self->next::method( @_ );

    $rv->storage->sql_maker->quote_char('"');
    $rv->storage->sql_maker->name_sep('.');

    return $rv;
}

=head2 do_connect

Connects to the database specified in the active GMS::Web config files.

=cut

use GMS::Config;

sub do_connect {
    my $self = shift;

    my $connectinfo = GMS::Config->database;

    $self->connect(
        $connectinfo->{dsn},
        $connectinfo->{user},
        $connectinfo->{password},
        $connectinfo);
}


# You can replace this text with custom content, and it will be preserved on regeneration
1;
