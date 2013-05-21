package GMS::Web::Controller::Logout;

use strict;
use warnings;
use base qw (GMS::Web::TokenVerification);

=head1 NAME

GMS::Web::Controller::Logout - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 base

=cut

sub base :Chained('/') :PathPart('logout') :CaptureArgs(0) :DestroyToken {
}

=head2 index

=cut

sub index :Chained('base') :PathPart('') :Args(0){
    my ( $self, $c ) = @_;

    $c->logout;
    $c->flash->{status_msg} = "You have successfully logged out.";
    $c->response->redirect($c->uri_for('/'));
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
