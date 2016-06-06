package GMS::Web::Action::UpdateSession;

use strict;
use warnings;

use base qw(Catalyst::Action);
use MRO::Compat;

=head1 NAME

GMS::Web::Action::UpdateSession - Updates the session id without deleting data

=head1 DESCRIPTION

Used to generate a new session upon logging in.

=cut

=head1 METHODS

=head2 execute

Updates the session token.

=cut

sub execute {
    my $self = shift;
    my ( $controller, $c, @args ) = @_;

    $c->change_session_id;

    return $self->next::method(@_);
}

1;
