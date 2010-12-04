package GMS::Authentication::Test::Store;

use strict;
use warnings;

use base 'Class::Accessor::Fast';

use GMS::Authentication::Test::User;

BEGIN {
    __PACKAGE__->mk_accessors(qw/userhash/);
}

=head1 NAME

GMS::Authentication::Test::Store

=head1 DESCRIPTION

A 'dummy' Store for L<Catalyst::Plugin::Authentication>, used for GMS::Web unit
tests.

This module is designed to operate similarly to
L<Catalyst::Authentication::Store::Minimal>, but return a
L<GMS::Authentication::User> object that GMS can use.

=head1 METHODS

=head2 new

Constructs a store, using the 'users' element of the supplied config.

=cut

sub new {
    my ( $class, $config, $app, $realm) = @_;

    bless { userhash => $config->{'users'} }, $class;
}

=head2 for_session

Returns the user's account ID, to be stored in a session.

=cut

sub for_session {
    my ($self, $c, $user) = @_;

    return $user->get('id');;
}

=head2 from_session

Returns a user object for a given account ID, retrieved from a session.

=cut

sub from_session {
    my ($self, $c, $frozenuser) = @_;

    return GMS::Authentication::User->new(
        $c->model('DB::Account')->find({id => $frozenuser})
    );
}

=head2 find_user

Find a user from the supplied authinfo hash and return it.

=cut

sub find_user {
    my ($self, $authinfo, $c) = @_;

    my $username = $authinfo->{id} || $authinfo->{username};

    my $user = $self->userhash->{$username};

    return GMS::Authentication::Test::User->new(
        $user,
        $c->model('DB::Account')->find({ id => $user->{accountid} })
    );
}


1;
