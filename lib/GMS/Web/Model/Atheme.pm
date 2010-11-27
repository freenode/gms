package GMS::Web::Model::Atheme;

use strict;
use warnings;

use base 'Catalyst::Model';

use RPC::Atheme::Session;

sub start_session {
    my ($self) = @_;

    if ($self->{_session}) {
        $self->{_session}->logout;
        undef $self->{_session};
    }

    my $session = RPC::Atheme::Session->new(
        $self->{hostname}, $self->{port}
    );

    $session->login(
        $self->{master_account}, $self->{master_password}, "GMS:internal"
    );

    $self->{_session} = $session;

    return $session;
}

sub session {
    my ($self) = @_;
    if ($self->{_session}) {
        return $self->{_session};
    }
    return $self->start_session;
}

1;
