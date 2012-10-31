package GMS::Web::Action::GenerateToken;

use strict;
use warnings;

use base qw(Catalyst::Action);
use MRO::Compat;

=head1 NAME

GMS::Web::Action::GenerateToken - Token Creation Action for GMS

=head1 DESCRIPTION

GMS::Web::Action::GenerateToken will be called when we need
to create a token.

=cut

=head1 METHODS

=head2 execute

Creates the token that will be used to validate
form submission in this session.

=cut

sub execute {
    my $self = shift;
    my ( $controller, $c, @args ) = @_;

    $c->controller->generate_token($c);
    return $self->next::method(@_);
}

1;
