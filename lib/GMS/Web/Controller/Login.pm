package GMS::Web::Controller::Login;

use strict;
use warnings;
use base qw (GMS::Web::TokenVerification GMS::Web::SessionManagement);

use TryCatch;

=head1 NAME

GMS::Web::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 base

=cut

sub base :Chained('/') :PathPart('login') :CaptureArgs(0) {
}

=head2 index

Displays the login form

=cut

sub index :Chained('base') :PathPart('') :Args(0) :Local :GenerateToken {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'login.tt';
}

=head2 do_login

Processes the form, sees if we can log in with the provided credentials.

=cut

sub do_login :Chained('base') :PathPart('submit') :Args(0) :Local :VerifyToken :UpdateSession {
    my ( $self, $c ) = @_;

    my $username = $c->request->params->{username} || "";
    my $password = $c->request->params->{password} || "";

    if ($username && $password) {
        try {
            if ($c->authenticate( { username => $username, password => $password } )) {
                $c->flash->{status_msg} = "You are now logged in as $username";
                $c->response->redirect($c->session->{redirect_to} || $c->uri_for('/'));
                delete $c->session->{redirect_to};

                return;
            } else {
                $c->stash->{error_msg} = "Invalid username or password";
            }
        } catch (RPC::Atheme::Error $e) {
            $c->stash->{error_msg} = $e->description;
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
