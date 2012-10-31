package GMS::Web::Action::DestroyToken;

use strict;
use warnings;

use base qw(Catalyst::Action);
use MRO::Compat;

=head1 NAME

GMS::Web::Action::DestroyToken - Destroy Token Action for GMS

=head1 DESCRIPTION

GMS::Web::Action::DestroyToken will be called when we need
to destroy the token.

=cut

=head1 METHODS

=head2 execute

Removes the token from the session.

=cut

sub execute {
    my $self = shift;
    my ( $controller, $c, @args ) = @_;

    $c->controller->destroy_token($c);
    return $self->next::method(@_);
}

1;
