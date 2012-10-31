package GMS::Web::Action::VerifyToken;

use strict;
use warnings;

use base qw(Catalyst::Action);
use MRO::Compat;

=head1 NAME

GMS::Web::Action::VerifyToken - Token Verification Action for GMS

=head1 DESCRIPTION

GMS::Web::Action::VerifyToken will be called when we need
token verification on our forms.

=cut

=head1 METHODS

=head2 execute

If the current request is POST and our toket is invalid, show
a bad request page. Otherwise continue normally.

=cut

sub execute {
    my $self = shift;
    my ( $controller, $c, @args ) = @_;

    if (scalar keys $c->request->body_params && !$controller->is_valid_token ($c)) {
        $c->detach ("/bad_request");
    }

    return $self->next::method(@_);
}

1;
