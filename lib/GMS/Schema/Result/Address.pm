package GMS::Schema::Result::Address;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('addresses');
__PACKAGE__->add_columns(qw/ id address_one address_two city state code country phone phone2 /);
__PACKAGE__->set_primary_key('id');

sub new {
    my $class = shift;
    my $args = shift;

    my @errors;
    my $valid = 1;

    if (! $args->{address_one}) {
        push @errors, "Address 1 is missing";
        $valid = 0;
    }
    if (! $args->{city}) {
        push @errors, "City is missing";
        $valid = 0;
    }
    if (! $args->{country}) {
        push @errors, "Country is missing";
        $valid = 0;
    }
    if (! $args->{phone}) {
        push @errors, "Telephone number is missing";
        $valid = 0;
    } elsif ($args->{phone} =~ /[^0-9 \+-]/) {
        push @errors, "Telephone number contains non-digit characters";
        $valid = 0;
    }
    if ($args->{phone2} =~ /[^0-9 \+-]/) {
        push @errors, "Alternate telephone number contains non-digit characters";
        $valid = 0;
    }

    if (!$valid) {
        die GMS::Exception::InvalidAddress->new(\@errors);
    }

    return $class->next::method($args);
}


sub pretty_long {
    my ($self) = @_;
    my $out = "";
    $out .= $self->address_one . "\n";
    $out .= $self->address_two . "\n" if $self->address_two;
    $out .= $self->city . "\n";
    $out .= $self->state . "\n" if $self->state;
    $out .= $self->country . "\n";
    $out .= $self->code . "\n" if $self->code;
    return $out;
}

1;

