package GMS::Web::SessionManagement;
use Moose;
BEGIN { extends 'Catalyst::Controller' }

use Digest;
use Catalyst::Exception;
use namespace::autoclean;

use strict;
use warnings;

=head1 NAME

GMS::Web::SessionManagement - Session management.

=head1 DESCRIPTION

Allows deleting and updating session cookies.

=cut

sub _parse_DeleteSession_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return (
        ActionClass => '+GMS::Web::Action::DeleteSession'
    );
}

sub _parse_UpdateSession_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return (
        ActionClass => '+GMS::Web::Action::UpdateSession'
    );
}

1;
