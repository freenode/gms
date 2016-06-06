package GMS::Web::Action::DeleteSession;

use strict;
use warnings;

use base qw(Catalyst::Action);
use MRO::Compat;

=head1 NAME

GMS::Web::Action::DeleteSession - Deletes the session.

=head1 DESCRIPTION

Used to generate a new session upon logging out.

=cut

=head1 METHODS

=head2 execute

Deletes the session.

=cut

sub execute {
    my $self = shift;
    my ( $controller, $c, @args ) = @_;

    $c->delete_session;

    return $self->next::method(@_);
}

1;
