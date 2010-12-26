package GMS::Authentication::Credential;

use strict;
use warnings;

use GMS::Session;
use GMS::Authentication::User;

use TryCatch;

=head1 NAME

GMS::Authentication::Credential

=head1 DESCRIPTION

Implements a Credential for L<Catalyst::Plugin::Authentication>, by
authenticating against Atheme via L<GMS::Session>.

=head1 METHODS

=head2 new

Constructor, as called by the Authentication plugin.

=cut

sub new {
    my ($class, $config, $app, $realm) = @_;
    $class = ref $class || $class;

    my $self = {
        _config => $config,
        _app => $app,
        _realm => $realm,
    };

    bless $self, $class;
}

=head2 authenticate

Authenticates a user, and returns a L<GMS::Authentication::User> if successful.
Otherwise, return undef.

=cut

sub authenticate {
    my ($self, $c, $realm, $authinfo) = @_;

    my $controlsession = $c->model('Atheme')->session;
    try {
        my $session = GMS::Session->new(
            $authinfo->{username},
            $authinfo->{password},
            $controlsession
        );

        return GMS::Authentication::User->new($session->account);
    } catch (RPC::Atheme::Error $e) {
        $c->log->debug("Couldn't log in to atheme as user " . $authinfo->{username} . ": $e");
        return undef;
    }
}

1;
