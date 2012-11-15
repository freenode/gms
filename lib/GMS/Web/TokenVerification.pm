package GMS::Web::TokenVerification;
use Moose;
BEGIN { extends 'Catalyst::Controller' }

use Digest;
use Catalyst::Exception;
use namespace::autoclean;

use strict;
use warnings;

=head1 NAME

GMS::Web::TokenVerification - CSRF protection for GMS

=head1 DESCRIPTION

GMS::Web::TokenVerification verifies that the form has been submitted
from the actual application, and not from an external POST request. This
is done to prevent cross-site request forgery (CSRF)

=cut

my $usable;

=head1 METHODS

=head2 _find_digest

Finds a usable Digest module to hash our token.
This method has been taken from Catalyst::Plugin::Session.

=cut

sub _find_digest () {
    unless ($usable) {
        foreach my $alg (qw/SHA-1 SHA-256 MD5/) {
            if ( eval { Digest->new($alg) } ) {
                $usable = $alg;
                last;
            }
        }
        Catalyst::Exception->throw(
                "Could not find a suitable Digest module. Please install "
              . "Digest::SHA1, Digest::SHA, or Digest::MD5" )
          unless $usable;
    }

    return Digest->new($usable);
}

=head2 generate_token

Generates the token that will be used in this session.
This method has been taken from Catalyst::Controller::RequestToken.

=cut

sub generate_token {
    my ($self, $c) = @_;

    my $digest = _find_digest();
    my $seed = join( time, rand(10000), $$, {} );
    $digest->add($seed);
    my $token = $digest->hexdigest;
    $self->{_token} = $token;
    $c->session->{_token} = $token;
}

=head2 destroy_token

Removes the token from the session.

=cut

sub destroy_token {
    my ($self, $c) = @_;

    undef $self->{_token};
    undef $c->session->{_token};
}

=head2 token

Returns the token (either from $self->{_token}, if we're putting it
in a form in the same page that created it, or from $c->session->{_token}
where it will be stored.

=cut

sub token {
    my ($self, $c) = @_;
    return ( $self->{_token} ? $self->{_token} : $c->session->{_token} );
}

=head2 is_vaid_token

Checks if the token provided over POST is the same as the one in the
session.

=cut

sub is_valid_token {
    my ($self, $c) = @_;
   
    return ($c->request->params->{_token} && $self->token($c) && $c->request->params->{_token} eq $self->token($c));
}

sub _parse_VerifyToken_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return (
        ActionClass => '+GMS::Web::Action::VerifyToken'
    );
}

sub _parse_GenerateToken_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return (
        ActionClass => '+GMS::Web::Action::GenerateToken'
    );
}

sub _parse_DestroyToken_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return (
        ActionClass => '+GMS::Web::Action::DestroyToken'
    );
}

1;
