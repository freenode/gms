package GMS::Exception;

use overload '""' => \&message;

sub new {
    my ($class, $message) = @_;
    $class = ref $class || $class;

    my $self = { message => $message };

    bless $self, $class;
}

sub message {
    my ($self) = @_;
    return $self->{message};
}

package GMS::Exception::InvalidGroup;

use base GMS::Exception;

package GMS::Exception::InvalidAddress;

use base GMS::Exception;

1;

