package GMS::Util::Address;

use strict;
use warnings;

sub validate_address {
    my ($addr, $errors) = @_;
    my $ret = 1;

    if (! $addr->{address_one}) {
        push @$errors, "Address 1 is missing";
        $ret = 0;
    }
    if (! $addr->{city}) {
        push @$errors, "City is missing";
        $ret = 0;
    }
    if (! $addr->{country}) {
        push @$errors, "Country is missing";
        $ret = 0;
    }
    if (! $addr->{phone_one}) {
        push @$errors, "Telephone number is missing";
        $ret = 0;
    } elsif ($addr->{phone_one} =~ /[^0-9 \+-]/) {
        push @$errors, "Telephone number contains non-digit characters";
    }

    return $ret;
}

1;
