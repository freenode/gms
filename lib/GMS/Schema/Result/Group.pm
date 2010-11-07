package GMS::Schema::Result::Group;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

GMS::Schema::Result::Group

=cut

__PACKAGE__->table("groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'groups_id_seq'

=head2 groupname

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 url

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 address

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 verify_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 verify_token

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 submitted

  data_type: 'timestamp'
  is_nullable: 0

=head2 verify_auto

  data_type: 'boolean'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "groups_id_seq",
  },
  "groupname",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "address",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "verify_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "verify_token",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "submitted",
  { data_type => "timestamp", is_nullable => 0 },
  "verify_auto",
  { data_type => "boolean", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("unique_verify", ["verify_url"]);
__PACKAGE__->add_unique_constraint("unique_name", ["groupname"]);

=head1 RELATIONS

=head2 channel_namespaces

Type: has_many

Related object: L<GMS::Schema::Result::ChannelNamespace>

=cut

__PACKAGE__->has_many(
  "channel_namespaces",
  "GMS::Schema::Result::ChannelNamespace",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 cloak_namespaces

Type: has_many

Related object: L<GMS::Schema::Result::CloakNamespace>

=cut

__PACKAGE__->has_many(
  "cloak_namespaces",
  "GMS::Schema::Result::CloakNamespace",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 group_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->has_many(
  "group_changes",
  "GMS::Schema::Result::GroupChange",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 group_contacts

Type: has_many

Related object: L<GMS::Schema::Result::GroupContact>

=cut

__PACKAGE__->has_many(
  "group_contacts",
  "GMS::Schema::Result::GroupContact",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 address

Type: belongs_to

Related object: L<GMS::Schema::Result::Address>

=cut

__PACKAGE__->belongs_to(
  "address",
  "GMS::Schema::Result::Address",
  { id => "address" },
  { join_type => "LEFT" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-07 23:11:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wZJMtArLBrMm8hpkhaEX+A

# Pseudo-relations not added by Schema::Loader
__PACKAGE__->many_to_many(contacts => 'group_contacts', 'contact');

use TryCatch;

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

sub verify {
    my ($self) = @_;
    if ($self->status ne 'auto_pending' && $self->status ne 'manual_pending') {
        die GMS::Exception->new("Can't verify a group that isn't pending verification");
    }
    $self->status('verified');
    $self->update;
}

sub approve {
    my ($self) = @_;
    if ($self->status ne 'verified' && $self->status ne 'manual_pending' && $self->status ne 'auto_pending') {
        die GMS::Exception->new("Can't approve a group that isn't verified or "
            . "pending verification");
    }
    $self->status('approved');
    $self->update;
}

sub reject {
    my ($self) = @_;
    if ($self->status ne 'verified' && $self->status ne 'manual_pending' && $self->status ne 'auto_pending') {
        die GMS::Exception->new("Can't reject a group not pending approval");
    }
    $self->status('rejected');
    $self->update;
}


# You can replace this text with custom content, and it will be preserved on regeneration
1;
