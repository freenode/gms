package GMS::Schema::Result::ChannelNamespace;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

GMS::Schema::Result::ChannelNamespace

=cut

__PACKAGE__->table("channel_namespaces");

=head1 ACCESSORS

=head2 group_id

  data_type: integer
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 namespace

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 32

=cut

__PACKAGE__->add_columns(
  "group_id",
  {
    data_type      => "integer",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "namespace",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 32,
  },
);
__PACKAGE__->add_unique_constraint("unique_channel_ns", ["namespace"]);

=head1 RELATIONS

=head2 group

Type: belongs_to

Related object: L<GMS::Schema::Result::Group>

=cut

__PACKAGE__->belongs_to("group", "GMS::Schema::Result::Group", { id => "group_id" }, {});


# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-04 23:06:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sxQb57lWexJR6LCbV4jZSw

sub insert {
    my $self = shift;
    try {
        return $self->next::method(@_);
    }
    catch (DBIx::Class::Exception $e) {
        if ("$e" =~ /unique_channel_ns/) {
            die GMS::Exception->new("The channel namespace " . $self->namespace .
                                    " has already been claimed.");
        } else {
            die $e;
        }
    }
}


# You can replace this text with custom content, and it will be preserved on regeneration
1;
