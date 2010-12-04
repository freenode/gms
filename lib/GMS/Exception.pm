package GMS::Exception;

use overload '""' => \&message;

=head1 NAME

GMS::Exception

=head1 DESCRIPTION

Base class for exceptions thrown in GMS.

=head1 METHODS

=head2 new

    GMS::Exception->new("some message here");

Constructor. Takes a message argument.

=cut

sub new {
    my ($class, $message) = @_;
    $class = ref $class || $class;

    my $self = { message => $message };

    bless $self, $class;
}

=head2 message

Returns the message given during construction.

=cut

sub message {
    my ($self) = @_;
    return $self->{message};
}

package GMS::Exception::InvalidGroup;

use base GMS::Exception;

package GMS::Exception::InvalidAddress;

use base GMS::Exception;

1;

