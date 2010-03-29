package GMS::Schema::Result::UserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

GMS::Schema::Result::UserRole

=cut

__PACKAGE__->table("user_roles");

=head1 ACCESSORS

=head2 account_id

  data_type: integer
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 role_id

  data_type: integer
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "account_id",
  {
    data_type      => "integer",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "role_id",
  {
    data_type      => "integer",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("account_id", "role_id");

=head1 RELATIONS

=head2 account

Type: belongs_to

Related object: L<GMS::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "account",
  "GMS::Schema::Result::Account",
  { id => "account_id" },
  {},
);

=head2 role

Type: belongs_to

Related object: L<GMS::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to("role", "GMS::Schema::Result::Role", { id => "role_id" }, {});


# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-04 23:06:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/gtvr0sXEu3ys0ogUAkocQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
