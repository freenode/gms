package GMS::Web::Model::Accounts;

use strict;
use warnings;

use base 'Catalyst::Model';

=head1 NAME

GMS::Web::Model::Accounts

=head1 DESCRIPTION

Catalyst model for GMS::Web which wraps around L<GMS::Domain::Accounts>.

=head1 INTERNAL_METHODS

=head2 ACCEPT_CONTEXT

Returns a new GMS::Domain::Accounts object.

=cut

sub ACCEPT_CONTEXT {
    my ($class, $c) = @_;

    return GMS::Domain::Accounts->new ($c->model('Atheme')->session, $c->model('DB')->schema);
}

1;
