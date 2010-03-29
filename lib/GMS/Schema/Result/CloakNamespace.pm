package GMS::Schema::Result::CloakNamespace;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

GMS::Schema::Result::CloakNamespace

=cut

__PACKAGE__->table("cloak_namespaces");

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
__PACKAGE__->add_unique_constraint("cloak_namespaces_namespace_key", ["namespace"]);

=head1 RELATIONS

=head2 group

Type: belongs_to

Related object: L<GMS::Schema::Result::Group>

=cut

__PACKAGE__->belongs_to("group", "GMS::Schema::Result::Group", { id => "group_id" }, {});


# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-04 23:06:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:efsC6AhD0mriAVB71SI5nA

__PACKAGE__->belongs_to('group', 'GMS::Schema::Result::Group', 'group_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
