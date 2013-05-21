package GMS::Exception;

use Moose;
with 'Throwable';

use overload
    '""' => \&as_string,
    fallback => 1;

with('MooseX::OneArgNew' => {
    type     => 'ArrayRef',
    init_arg => 'errors',
    required => 0,
    lazy => 1,
});

with('MooseX::OneArgNew' => {
    type     => 'Str',
    init_arg => 'msg',
});

has msg => (
    is   => 'ro',
    isa  => 'Str',

);

has errors => (
    is => 'ro',
    isa => 'ArrayRef',
);

=head1 NAME

GMS::Exception

=head1 DESCRIPTION

Base class for exceptions thrown in GMS.
Extends Throwable::Error.

=cut

=head1 METHODS

=head2 as_string

Return a stringified version of the error messages

=cut

sub as_string {
    my ($self) = @_;

    if ( $self->errors ) {
        my $errors = $self->errors;
        my @err = @$errors;

        return join ( "\n", @err );
    } else {
        return $self->msg;
    }
}

=head2 message

Returns either the string or array of errors,
depending on which is present.

=cut

sub message {
    my ($self) = @_;

    ( $self->msg ? $self->msg : $self->errors );
}

package GMS::Exception::InvalidGroup;

use base 'GMS::Exception';

package GMS::Exception::InvalidAddress;

use base 'GMS::Exception';

package GMS::Exception::InvalidChange;

use base 'GMS::Exception';

package GMS::Exception::InvalidNamespace;

use base 'GMS::Exception';

package GMS::Exception::InvalidCloakChange;

use base 'GMS::Exception';

package GMS::Exception::InvalidChannelRequest;

use base 'GMS::Exception';

package GMS::Exception::InvalidChange;

use base 'GMS::Exception';

1;
