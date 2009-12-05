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
    return { session => 1, roles => 1 };
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

sub account {
    my ($self) = @_;
    return $self->{_account};
}

sub roles {
    my ($self) = @_;
    #return $self->{_account}->roles;
    my @ret;
    foreach my $role ($self->{_account}->roles) {
        push @ret, $role->name;
    }
    return @ret;
}

1;
