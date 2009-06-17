package GMS::Web::Model::Atheme;

use strict;
use warnings;

use base 'Catalyst::Model';

use RPC::Atheme::Session;

sub new {
    my $self = shift->next::method(@_);

    my $session = RPC::Atheme::Session->new(
        $self->{atheme_host}, $self->{atheme_port}
    );

    $session->login(
        $self->{master_account}, $self->{master_password}, "GMS:internal"
    );

    $self->{_session} = $session;

    return $self;
}

sub session {
    my ($self) = @_;
    return $self->{_session};
}

1;
