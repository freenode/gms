package GMS::Schema::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

GMS::Schema::Result::Role

=cut

__PACKAGE__->table("roles");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'roles_id_seq'

=head2 name

  data_type: 'character varying'
  is_nullable: 0
  size: 32

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "roles_id_seq",
  },
  "name",
  { data_type => "character varying", is_nullable => 0, size => 32 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("roles_name_key", ["name"]);

=head1 RELATIONS

=head2 user_roles

Type: has_many

Related object: L<GMS::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "GMS::Schema::Result::UserRole",
  { "foreign.role_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.06000 @ 2010-03-30 20:57:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XvxAtHTcCY/zOeUvMUIq2w


# Pseudo-relations not added by Schema::Loader
__PACKAGE__->many_to_many(accounts => 'user_roles', 'account');


# You can replace this text with custom content, and it will be preserved on regeneration
1;
