package GMS::Authentication::Test::User;

use strict;
use warnings;

use base 'GMS::Authentication::User';

=head1 NAME

GMS::Authentication::Test::User

=head1 DESCRIPTION

Extends L<GMS::Authentication::User> to work with
L<GMS::Authentication::Test::Store> and
L<Catalyst::Authentication::Credential::Password>.

=head1 METHODS

=head2 new

Constructs a user object 

=cut

sub new {
    my ($self, $userhash, $account) = @_;

    my $ret = $self->next::method($account);
    $ret->{_userhash} = $userhash;
    return $ret;
}

=head2 get

Returns the value of the named fields. Valid fields are those for
L<GMS::Authentication::User>, plus 'password'.

=cut

sub get {
    my ($self, $field) = @_;

    return $self->{_userhash}->{password} if $field eq 'password';
    return $self->next::method($field);
}

1;
