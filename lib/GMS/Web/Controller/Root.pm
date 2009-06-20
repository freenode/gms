package GMS::Web::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

GMS::Web::Controller::Root - Root Controller for GMS::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->stash->{template} = 'index.tt';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

# TT-template test

sub tttest : Local {
    my ($self, $c) = @_;
    $c->stash->{error_msg} = "This is an error message.<br>\nIt has multiple lines.";
    $c->stash->{status_msg} = "You have successfully read this fake-status-message.<br>\nYour skill in reading was increased by one point.";
    $c->stash->{template} = 'tttest.tt';
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

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
        $c->response->redirect($c->uri_for('/login'));
        return 0;
    }

    return 1;
}

1;
