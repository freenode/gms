package GMS::Authentication::User;

use strict;
use warnings;

use base 'Catalyst::Authentication::User';

=head1 NAME

GMS::Authentication::User

=head1 DESCRIPTION

Implements a User object for L<Catalyst::Plugin::Authentication>, to go with
L<GMS::Authentication::Store>.

=head1 METHODS

=head2 uuid

Returns the Atheme UUID for the user.

=head2 id

Returns the numeric account ID for this user.

=head2 username

Returns the account name, as a string.

=head2 account

Returns a L<GMS::Schema::Account> object for this user.

=head2 authcookie

Returns the user's Atheme auth cookie.

=head2 roles

Returns an arrayref of strings for the roles that this user has.

=head2 INTERNAL METHODS

=head2 new

Constructor. Should only be called by L<GMS::Authentication::Credential>.

=head2 supported_features

Returns the list of supported features for this user object, which is 'session'
and 'roles'.

=head2 get($fieldname)

Returns the value of the field specified. Valid fields are 'id' and 'name',
which will return the values of id() and username() respectively.

=head2 get_object

Returns $self.

=cut

sub new {
    my ($class, $account, $authcookie) = @_;
    $class = ref $class || $class;

    my $self = {
        _account    => $account,
        _authcookie => $authcookie,
    };

    bless $self, $class;
}

sub id {
    my ($self) = @_;

    return $self->{_account}->id;
}

sub uuid {
    my ($self) = @_;

    return $self->{_account}->uuid;
}

sub supported_features {
    return { session => 1, roles => 1 };
}

sub get {
    my ($self, $fieldname) = @_;

    return $self->{_account}->id if $fieldname eq "id";
    return $self->{_account}->uuid if $fieldname eq "uuid";
    return $self->{_authcookie} if $fieldname eq "authcookie";
    return $self->{_account}->accountname if $fieldname eq "name";
    return undef;
}

sub get_object {
    my ($self) = @_;

    return $self;
}

sub authcookie {
    my ($self) = @_;
    return $self->get('authcookie');
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
