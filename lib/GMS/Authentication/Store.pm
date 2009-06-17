package GMS::Authentication::Store;

use strict;
use warnings;

use GMS::Authentication::User;

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

    return $user->get('id');;
}

sub from_session {
    my ($self, $c, $frozenuser) = @_;

    return GMS::Authentication::User->new(
        $c->model('DB::Account')->find({id => $frozenuser})
    );
}

1;
