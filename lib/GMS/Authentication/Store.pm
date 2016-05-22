package GMS::Authentication::Store;

use strict;
use warnings;

use GMS::Authentication::User;

=head1 NAME

GMS::Authentication::Store

=head1 DESCRIPTION

Implements a Store for L<Catalyst::Plugin::Authentication>, taking user
definitions from the GMS database.

This does not quite look like a 'normal' store definition, since GMS accounts
are created (or renamed) on demand based on Atheme authentication. At present
this means that user objects are created by the Credential, not the Store.

=head1 INTERNAL METHODS

=head2 new

Constructor. Called by the Authentication plugin.

=head2 for_session

Returns a user's account ID to be stored in a session.

=head2 from_session

Constructs a user object from an account ID.

=cut

sub new {
    my ($class, $config, $app, $realm) = @_;
    $class = ref $class || $class;

    my $self = {
        _config => $config,
        _app => $app,
        _realm => $realm
    };

    bless $self, $class;
}

sub for_session {
    my ($self, $c, $user) = @_;

    return {
        'id'            => $user->get('uuid'),
        'authcookie'    => $user->get('authcookie'),
    };
}

sub from_session {
    my ($self, $c, $frozenuser) = @_;

    my $account = $c->model('DB::Account')->find({uuid => $frozenuser->{'id'}});
    return if !$account;

    return GMS::Authentication::User->new($account, $frozenuser->{authcookie});
}

1;
