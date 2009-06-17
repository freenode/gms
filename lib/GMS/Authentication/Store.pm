package GMS::Authentication::Store;

use strict;
use warnings;

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

    return $user->account_id;
}

sub from_session {
    my ($self, $c, $frozenuser) = @_;

    return $c->model('DB::Account')->find(account_id => $frozenuser);
}

1;
