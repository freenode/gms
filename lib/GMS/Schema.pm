use utf8;
package GMS::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

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

=head2 install_defaults

Install data for DBIx::Class::DeploymentHandler.
Do nothing for now.

=cut

sub install_defaults { }

our $VERSION = 6;

1;
