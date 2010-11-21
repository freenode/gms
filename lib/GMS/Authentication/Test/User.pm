package GMS::Authentication::Test::User;

use strict;
use warnings;

use base 'GMS::Authentication::User';

sub new {
    my ($self, $userhash, $account) = @_;

    my $ret = $self->next::method($account);
    $ret->{_userhash} = $userhash;
    return $ret;
}

sub get {
    my ($self, $field) = @_;

    return $self->{_userhash}->{password} if $field eq 'password';
    return $self->next::method($field);
}

1;
