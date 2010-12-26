package GMS::Schema::Result::GroupChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head1 NAME

GMS::Schema::Result::GroupChange

=cut

__PACKAGE__->table("group_changes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'group_changes_id_seq'

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 time

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 changed_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 change_type

  data_type: 'enum'
  extra: {custom_type_name => "change_type",list => ["create","request","approve","admin"]}
  is_nullable: 0

=head2 group_type

  data_type: 'enum'
  extra: {custom_type_name => "group_type",list => ["informal","corporation","education","government","nfp","internal"]}
  is_nullable: 0

=head2 url

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 address

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 status

  data_type: 'enum'
  extra: {custom_type_name => "group_status",list => ["submitted","verified","active","deleted"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "group_changes_id_seq",
  },
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "time",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "changed_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "change_type",
  {
    data_type => "enum",
    extra => {
          custom_type_name => "change_type",
          list => ["create", "request", "approve", "admin"],
        },
    is_nullable => 0,
  },
  "group_type",
  {
    data_type => "enum",
    extra => {
          custom_type_name => "group_type",
          list => [
                "informal",
                "corporation",
                "education",
                "government",
                "nfp",
                "internal",
              ],
        },
    is_nullable => 0,
  },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "address",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "status",
  {
    data_type => "enum",
    extra => {
          custom_type_name => "group_status",
          list => ["submitted", "verified", "active", "deleted"],
        },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 group

Type: belongs_to

Related object: L<GMS::Schema::Result::Group>

=cut

__PACKAGE__->belongs_to("group", "GMS::Schema::Result::Group", { id => "group_id" }, {});

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

=head2 changed_by

Type: belongs_to

Related object: L<GMS::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "changed_by",
  "GMS::Schema::Result::Account",
  { id => "changed_by" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:18:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Q1vpIkhh6TFQkXLLCABbRA

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
