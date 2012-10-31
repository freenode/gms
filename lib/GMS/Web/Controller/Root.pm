package GMS::Web::Controller::Root;

use strict;
use warnings;
use base qw (GMS::Web::TokenVerification);

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

GMS::Web::Controller::Root - Root Controller for GMS::Web

=head1 DESCRIPTION

This module contains what small amount of global logic there is in GMS::Web.

The front page and global error handlers are here, as is the code to ensure
that a user is logged in before allowing any other operations.

=head1 METHODS

=cut

=head2 index

Presents the front page.

=cut

sub index :Path :Args(0) :Local :GenerateToken {
    my ( $self, $c ) = @_;

    # Hello World
    $c->stash->{template} = 'index.tt';
}

=head2 default

The default handler, used when no other matches. This simply presents a 404
error page.

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'error/404.tt';
    $c->response->status(404);
}

=head2 forbidden

This method should not be reached directly, but instead through detach() calls
where other controllers have determined that the user lacks access to the page
requested.

It presents a 403 error page.

=cut

sub forbidden :Path('403') :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = 'error/403.tt';
    $c->response->status(403);
}

=head2 bad_request

This page is shown if the client has made a bad request. This also includes cases
where an invalid token is provided when submitting the form, or the token is missing altogether
(when it shouldn't be).

It presents a 400 error page.

=cut

sub bad_request :Path('400') :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = 'error/400.tt';
    $c->response->status(400);
}


=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head2 auto

Called before all operations in all controllers. Ensures that the user
is logged in before allowing any operations other than login and those
in the root controller.

=cut

sub auto : Private {
    my ($self, $c) = @_;
    if ($c->controller eq $c->controller('Login') ||
        $c->controller eq $c->controller('Root'))
    {
        return 1;
    }

    if (!$c->user_exists)
    {
        $c->session->{redirect_to} = $c->request->uri;
        $c->response->redirect($c->uri_for('/login'));
        return 0;
    }

    return 1;
}

=head1 AUTHOR

Stephen Bennett <spb@exherbo.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
