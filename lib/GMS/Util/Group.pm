package GMS::Util::Group;

use strict;
use warnings;

use GMS::Util::Address;

use String::Random qw(random_string);

sub validate_group {
    my ($group, $errors) = @_;
    my $ret = 1;

    if (!$group->{group_type}) {
        push @$errors, "Group type must be specified";
        $ret = 0;
    }
    if (!$group->{group_name}) {
        push @$errors, "Group name must be provided";
        $ret = 0;
    }
    if ($group->{group_name} !~ /^[A-Za-z0-9 _\.-]*$/) {
        push @$errors, "Group name must contain only alphanumeric characters, space, " .
                       "underscores, hyphens and dots.";
        $ret = 0;
    }
    if (!$group->{group_url}) {
        push @$errors, "Group URL must be provided";
        $ret = 0;
    }
    if ($group->{group_url} !~ /^[a-zA-Z0-9:\.\/_?+-]*$/) {
        push @$errors, "Group URL contains invalid characters (valid characters are a-z, A-Z, " .
                       "0-9, :_+-/)";
        $ret = 0;
    }
    if ($group->{channel_namespace}) {
        my $err = 0;
        foreach my $ch (split /, */, $group->{channel_namespace}) {
            $err = 1 if ($ch !~ /^#[a-zA-Z0-9_\.\*-]+$/)
        }
        if ($err) {
            push @$errors, "Channel namespaces must be a comma-separated list of valid channel " .
                           "masks.";
            $ret = 0;
        }
    }
    if ($group->{has_address} eq "y") {
        my @addr_errors;
        if (! GMS::Util::Address::validate_address($group, \@addr_errors)) {
            push @$errors, "The group was marked as having an address, but a valid address was" .
                           "not provided.";
            push @$errors, @addr_errors;
            $ret = 0;
        }
    }

    return $ret;
}

sub generate_validation_url {
    my ($baseurl) = @_;

    return $baseurl . '/' . random_string("cccccccc") . ".txt";
}

sub generate_validation_token {
    return random_string("................");
}

1;
