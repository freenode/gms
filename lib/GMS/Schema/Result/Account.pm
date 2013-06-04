package GMS::Schema::Result::Account;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum","InflateColumn::Boolean","Core");

=head1 NAME

GMS::Schema::Result::Account

=cut

__PACKAGE__->table("accounts");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  is_nullable: 0
  size: 9

=head2 accountname

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 dropped

  data_type: 'int'
  is_nullable: 0
  is_boolean:  1
  default_value: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "varchar",
    is_nullable       => 0,
    size              => 9
  },
  "accountname",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "dropped",
  {
    data_type         => "int",
    is_nullable       => 0,
    is_boolean        => 1,
    default_value     => 0
  }
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contact_changes

Type: has_many

Related object: L<GMS::Schema::Result::ContactChange>

=cut

__PACKAGE__->has_many(
  "contact_changes",
  "GMS::Schema::Result::ContactChange",
  { "foreign.changed_by" => "self.id" },
  {},
);

=head2 contact

Type: might_have

Related object: L<GMS::Schema::Result::Contact>

=cut

__PACKAGE__->might_have(
  "contact",
  "GMS::Schema::Result::Contact",
  { "foreign.account_id" => "self.id" },
  {},
);

=head2 group_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->has_many(
  "group_changes",
  "GMS::Schema::Result::GroupChange",
  { "foreign.changed_by" => "self.id" },
  {},
);

=head2 group_contact_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupContactChange>

=cut

__PACKAGE__->has_many(
  "group_contact_changes",
  "GMS::Schema::Result::GroupContactChange",
  { "foreign.changed_by" => "self.id" },
  {},
);

=head2 user_roles

Type: has_many

Related object: L<GMS::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "GMS::Schema::Result::UserRole",
  { "foreign.account_id" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-08 18:18:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FH/6Tttyq3dvSGGttsDJ3Q

# You can replace this text with custom content, and it will be preserved on regeneration

# Pseudo-relations not added by Schema::Loader
__PACKAGE__->many_to_many(roles => 'user_roles', 'role');

__PACKAGE__->has_many(
    "recent_cloak_changes",
    "GMS::Schema::Result::CloakChange",
    { "foreign.target" => "self.id" },
    {
        "join" => "active_change",
        "where" => { "active_change.status" => [ "approved", "applied" ] }
    }
);

1;
