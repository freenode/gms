use utf8;
package GMS::Schema::Result::Account;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

GMS::Schema::Result::Account

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<accounts>

=cut

__PACKAGE__->table("accounts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'accounts_id_seq'

=head2 uuid

  data_type: 'varchar'
  is_nullable: 0
  size: 9

=head2 accountname

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 dropped

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "uuid",
  { data_type => "varchar", is_nullable => 0, size => 9 },
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "accounts_id_seq",
  },
  "accountname",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "dropped",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<unique_uuid>

=over 4

=item * L</uuid>

=back

=cut


__PACKAGE__->add_unique_constraint("unique_uuid", ["uuid"]);

=head1 RELATIONS

=head2 channel_namespace_changes

Type: has_many

Related object: L<GMS::Schema::Result::ChannelNamespaceChange>

=cut

__PACKAGE__->has_many(
  "channel_namespace_changes",
  "GMS::Schema::Result::ChannelNamespaceChange",
  { "foreign.changed_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 channel_request_changes

Type: has_many

Related object: L<GMS::Schema::Result::ChannelRequestChange>

=cut

__PACKAGE__->has_many(
  "channel_request_changes",
  "GMS::Schema::Result::ChannelRequestChange",
  { "foreign.changed_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 channel_requests

Type: has_many

Related object: L<GMS::Schema::Result::ChannelRequest>

=cut

__PACKAGE__->has_many(
  "channel_requests",
  "GMS::Schema::Result::ChannelRequest",
  { "foreign.target" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 cloak_change_changes

Type: has_many

Related object: L<GMS::Schema::Result::CloakChangeChange>

=cut

__PACKAGE__->has_many(
  "cloak_change_changes",
  "GMS::Schema::Result::CloakChangeChange",
  { "foreign.changed_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 cloak_changes

Type: has_many

Related object: L<GMS::Schema::Result::CloakChange>

=cut

__PACKAGE__->has_many(
  "cloak_changes",
  "GMS::Schema::Result::CloakChange",
  { "foreign.target" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 cloak_namespace_changes

Type: has_many

Related object: L<GMS::Schema::Result::CloakNamespaceChange>

=cut

__PACKAGE__->has_many(
  "cloak_namespace_changes",
  "GMS::Schema::Result::CloakNamespaceChange",
  { "foreign.changed_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 contact

Type: might_have

Related object: L<GMS::Schema::Result::Contact>

=cut

__PACKAGE__->might_have(
  "contact",
  "GMS::Schema::Result::Contact",
  { "foreign.account_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 contact_changes

Type: has_many

Related object: L<GMS::Schema::Result::ContactChange>

=cut

__PACKAGE__->has_many(
  "contact_changes",
  "GMS::Schema::Result::ContactChange",
  { "foreign.changed_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 group_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->has_many(
  "group_changes",
  "GMS::Schema::Result::GroupChange",
  { "foreign.changed_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 group_contact_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupContactChange>

=cut

__PACKAGE__->has_many(
  "group_contact_changes",
  "GMS::Schema::Result::GroupContactChange",
  { "foreign.changed_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<GMS::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "GMS::Schema::Result::UserRole",
  { "foreign.account_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-07 14:42:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:D9sxJe/DSz2BzGYuW6N8Gg
# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum","Core");

# Pseudo-relations not added by Schema::Loader

__PACKAGE__->has_many(
    "recent_cloak_changes",
    "GMS::Schema::Result::CloakChange",
    { "foreign.target" => "self.id" },
    {
        "join" => "active_change",
        "where" => { "active_change.status" => [ "approved", "applied" ] }
    }
);

=head2 is_dropped

Returns if an account is dropped.

=cut

sub is_dropped {
    my ($self) = @_;

    return ( $self->dropped ? 1 : 0 );
}

=head2 TO_JSON

Returns a representative object for the JSON parser.

=cut

sub TO_JSON {
    my ($self) = @_;

    return {
        accountname => $self->accountname,
        id          => $self->id,
        dropped     => $self->is_dropped,
    };
}

1;
