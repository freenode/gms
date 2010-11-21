package GMS::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-06 23:44:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:U5sbcfVHhUtE3hElE/pYOQ

=head1 NAME

GMS::Schema

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

=head1 do_connect

Connects to the database specified in the active GMS::Web config files.

=cut

use GMS::Config;

sub do_connect {
    my $self = shift;

    $self->connect(
        $GMS::Config::dbstring,
        $GMS::Config::dbuser,
        $GMS::Config::dbpass,
        $GMS::Config::dbconnectinfo);
}


# You can replace this text with custom content, and it will be preserved on regeneration
1;
