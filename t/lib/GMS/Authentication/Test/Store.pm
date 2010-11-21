package GMS::Authentication::Test::Store;

use strict;
use warnings;

use base 'Class::Accessor::Fast';

use GMS::Authentication::Test::User;

BEGIN {
    __PACKAGE__->mk_accessors(qw/userhash/);
}

sub new {
    my ( $class, $config, $app, $realm) = @_;

    bless { userhash => $config->{'users'} }, $class;
}

sub for_session {
    my ($self, $c, $user) = @_;

    return $user->get('id');;
}

sub from_session {
    my ($self, $c, $frozenuser) = @_;

    return GMS::Authentication::User->new(
        $c->model('DB::Account')->find({id => $frozenuser})
    );
}

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
