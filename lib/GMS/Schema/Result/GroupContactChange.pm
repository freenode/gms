package GMS::Schema::Result::GroupContactChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head1 NAME

GMS::Schema::Result::GroupContactChange

=cut

__PACKAGE__->table("group_contact_changes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'group_contact_changes_id_seq'

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 contact_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 primary

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 status

  data_type: 'enum'
  extra: {custom_type_name => "group_contact_status",list => ["invited","retired","active"]}
  is_nullable: 0

=head2 change_type

  data_type: 'enum'
  extra: {custom_type_name => "change_type",list => ["create","request","approve","reject","admin","workflow_change"]}
  is_nullable: 0

=head2 changed_by

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0

=head2 affected_change

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

=head2 change_freetext

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "group_contact_changes_id_seq",
  },
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "contact_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "primary",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "status",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "group_contact_status",
      list => ["invited", "retired", "active"],
    },
    is_nullable => 0,
  },
  "change_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "change_type",
      list => ["create", "request", "approve", "reject", "admin", "workflow_change"],
    },
    is_nullable => 0,
  },
  "changed_by",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0 },
  "affected_change",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "change_freetext",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 group_contact

Type: belongs_to

Related object: L<GMS::Schema::Result::GroupContact>

=cut

__PACKAGE__->belongs_to(
  "group_contact",
  "GMS::Schema::Result::GroupContact",
  { contact_id => "contact_id", group_id => "group_id" },
  {},
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

=head2 affected_change

Type: belongs_to

Related object: L<GMS::Schema::Result::GroupContactChange>

=cut

__PACKAGE__->belongs_to(
  "affected_change",
  "GMS::Schema::Result::GroupContactChange",
  { id => "affected_change" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 20:23:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9euiunr7RSVF/p69PMnzOA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->add_columns(
    '+change_type' => { is_enum => 1 },
    '+status' => { is_enum => 1 },
);

use TryCatch;

use GMS::Exception;

=head1 METHODS

=head2 approve

    $change->approve ($approving_account, $freetext);

If the given change is a request, then create and return a new change identical
to it except for the type, which will be 'approve', the user, which must be
provided, and the optional free text about the change. The effect is to
approve the given request.

If the given change isn't a request, calling this is an error.

=cut

sub approve {
    my ($self, $account, $freetext) = @_;

    die GMS::Exception::InvalidChange->new("Can't approve a change that isn't a request")
        unless $self->change_type eq 'request';

    die GMS::Exception::InvalidChange->new("Need an account to approve a change") unless $account;

    my $ret = $self->group_contact->active_change($self->copy({ change_type => 'approve', changed_by => $account, affected_change => $self->id, change_freetext => $freetext }));
    $self->group_contact->update;
    return $ret;
}

=head2 reject

Similar to approve but reverts the group contact's previous active change with the change_type being 'reject'.

=cut

sub reject {
    my ($self, $account, $freetext) = @_;

    die GMS::Exception::InvalidChange->new("Can't reject a change that isn't a request")
        unless $self->change_type eq 'request';

    die GMS::Exception::InvalidChange->new("Need an account to reject a change") unless $account;

    my $previous = $self->group_contact->active_change;
    my $ret = $self->group_contact->active_change ($previous->copy({ change_type => 'reject', changed_by => $account, affected_change => $self->id, change_freetext => $freetext }));

    $self->group_contact->update;
    return $ret;
}

1;
