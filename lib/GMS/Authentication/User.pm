package GMS::Authentication::User;

use strict;
use warnings;

use base 'Catalyst::Authentication::User';

sub new {
    my ($class, $account) = @_;
    $class = ref $class || $class;

    my $self = {
        _account => $account
    };

    bless $self, $class;
}

sub id {
    my ($self) = @_;

    return $self->{_account}->id;
}

sub supported_features {
    return { session => 1 };
}

sub get {
    my ($self, $fieldname) = @_;

    return $self->{_account}->id if $fieldname eq "id";
    return $self->{_account}->accountname if $fieldname eq "name";
    return undef;
}

sub get_object {
    my ($self) = @_;

    return $self;
}

sub username {
    my ($self) = @_;
    return $self->get('name');
}

1;
