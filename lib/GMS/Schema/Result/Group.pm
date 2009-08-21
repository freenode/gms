package GMS::Schema::Result::Group;
use strict;
use warnings;
use base 'DBIx::Class';

use Error qw/:try/;
use Error::Simple;

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

sub use_automatic_verification {
    my ($self) = @_;
    my $name = $self->groupname;
    my $url = $self->url;
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
        throw Error::Simple->new("Can't auto-verify a group that isn't pending automatic verification");
    }
    $self->status('auto_verified');
    $self->update;
}

1;
