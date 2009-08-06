package GMS::Web::Controller::Login;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Error qw/:try/;

=head1 NAME

GMS::Web::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $username = $c->request->params->{username} || "";
    my $password = $c->request->params->{password} || "";

    if ($username && $password) {
        if ($c->authenticate( { username => $username, password => $password } )) {
            $c->stash->{status_msg} = "You have successfully logged in as $username";
            $c->response->redirect($c->uri_for('/'));
            return;
        } else {
            $c->stash->{error_msg} = "Invalid username or password";
        }
    }

    $c->stash->{template} = 'login.tt';
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
