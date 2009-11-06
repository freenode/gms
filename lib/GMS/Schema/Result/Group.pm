package GMS::Schema::Result::Group;
use strict;
use warnings;
use base 'DBIx::Class';

use TryCatch;

use String::Random qw/random_string/;

__PACKAGE__->load_components('Core');
__PACKAGE__->table('groups');
__PACKAGE__->add_columns(qw/ id groupname grouptype url address status verify_url verify_token
                             submitted verified approved /);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(group_contacts => 'GMS::Schema::Result::GroupContact', 'group_id');
__PACKAGE__->many_to_many(contacts => 'group_contacts', 'contact');

__PACKAGE__->belongs_to(address => 'GMS::Schema::Result::Address', 'address');

__PACKAGE__->has_many(channel_namespaces => 'GMS::Schema::Result::ChannelNamespace', 'group_id');
__PACKAGE__->has_many(cloak_namespaces => 'GMS::Schema::Result::CloakNamespace', 'group_id');

sub new {
    my $class = shift;
    my $args = shift;

    my @errors;
    my $valid=1;

    if (!$args->{grouptype}) {
        push @errors, "Group type must be specified";
        $valid = 0;
    }
    if (!$args->{groupname}) {
        push @errors, "Group name must be provided";
        $valid = 0;
    }
    if ($args->{groupname} !~ /^[A-Za-z0-9 _\.-]*$/) {
        push @errors, "Group name must contain only alphanumeric characters, space, " .
                       "underscores, hyphens and dots.";
        $valid = 0;
    }
    if (!$args->{url}) {
        push @errors, "Group URL must be provided";
        $valid = 0;
    }
    if ($args->{url} !~ /^[a-zA-Z0-9:\.\/_?+-]*$/) {
        push @errors, "Group URL contains invalid characters (valid characters are a-z, A-Z, " .
                       "0-9, :_+-/)";
        $valid = 0;
    }

    if (!$valid) {
        die GMS::Exception::InvalidGroup->new(\@errors);
    }

    my %newargs = %$args;

    if (use_automatic_verification($newargs{groupname}, $newargs{url})) {
        $newargs{status} = 'auto_pending';
    } else {
        $newargs{status} = 'manual_pending';
    }

    if (!$newargs{verify_url}) {
        $newargs{verify_url} = $newargs{url}."/".random_string("cccccccc").".txt";
    }
    if (!$newargs{verify_token}) {
        $newargs{verify_token} = random_string("cccccccccccc");
    }

    return $class->next::method(\%newargs);
}

sub insert {
    my $self=shift;
    try {
        return $self->next::method(@_);
    }
    catch (DBIx::Class::Exception $e) {
        if ("$e" =~ /unique_group_name/) {
            die GMS::Exception->new("A group with that name already exists.");
        } else {
            die $e;
        }
    }
}

sub use_automatic_verification {
    my ($name, $url) = @_;
    $url =~ tr/A-Z/a-z/;
    $url =~ s!http://!!;
    $url =~ s!www\.!!;
    $url =~ s!\.[a-z]+/?!!;
    $name =~ tr/A-Z/a-z/;
    $name =~ s/\W//g;

    return $name eq $url;
}

sub simple_url {
    my ($self) = @_;
    my $url = $self->url;
    $url =~ tr/A-Z/a-z/;

    if ($url !~ m!^[a-z]+://!) {
        $url = "http://" . $url;
    }

    $url =~ s/\/$//;
    return $url;
}

sub auto_verify {
    my ($self) = @_;
    if ($self->status ne 'auto_pending') {
        die GMS::Exception->new("Can't auto-verify a group that isn't pending automatic verification");
    }
    $self->status('auto_verified');
    $self->update;
}

1;
