package GMS::Authentication::Credential;

use strict;
use warnings;

use GMS::Session;

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
    } otherwise {
        return undef;
    }
}

1;
