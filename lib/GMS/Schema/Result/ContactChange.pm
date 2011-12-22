package GMS::Schema::Result::ContactChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head1 NAME

GMS::Schema::Result::ContactChange

=cut

__PACKAGE__->table("contact_changes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'contact_changes_id_seq'

=head2 contact_id

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

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 address

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 email

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 change_type

  data_type: 'enum'
  extra: {custom_type_name => "change_type",list => ["create","request","approve","reject","admin","workflow_change"]}
  is_nullable: 0

=cut

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
    sequence          => "contact_changes_id_seq",
  },
  "contact_id",
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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "address",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "change_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "change_type",
      list => ["create", "request", "approve", "reject", "admin", "workflow_change"],
    },
    is_nullable => 0,
  },
  "affected_change",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "change_freetext",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contact

Type: belongs_to

Related object: L<GMS::Schema::Result::Contact>

=cut

__PACKAGE__->belongs_to(
  "contact",
  "GMS::Schema::Result::Contact",
  { id => "contact_id" },
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

=head2 address

Type: belongs_to

Related object: L<GMS::Schema::Result::Address>

=cut

__PACKAGE__->belongs_to(
  "address",
  "GMS::Schema::Result::Address",
  { id => "address" },
  {},
);

=head2 affected_change

Type: belongs_to

Related object: L<GMS::Schema::Result::ContactChange>

=cut

__PACKAGE__->belongs_to(
  "affected_change",
  "GMS::Schema::Result::ContactChange",
  { id => "affected_change" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 20:23:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ncLmSRVDVaO6N1GJD95Xhg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

# Set enum columns to use Object::Enum
__PACKAGE__->add_columns(
    '+change_type' => { is_enum => 1 }
);

use TryCatch;

use GMS::Exception;

=head1 METHODS

=head2 approve

    $change->approve ($approving_account);

If the given change is a request, then create and return a new change identical
to it except for the type, which will be 'approve', and the user, which must be
provided.  The effect is to approve the given request.

If the given change isn't a request, calling this is an error.

=cut

sub approve {
    my ($self, $account) = @_;

    die GMS::Exception::InvalidChange->new("Can't approve a change that isn't a request")
        unless $self->change_type eq 'request';

    die GMS::Exception::InvalidChange->new("Need an account to approve a change") unless $account;

    my $ret = $self->contact->active_change($self->copy({ change_type => 'approve', changed_by => $account, affected_change => $self->id}));
    $self->contact->update;
    return $ret;
}

=head2 reject

Similar to approve but reverts the contact's previous active change with the change_type being 'reject'.

=cut

sub reject {
    my ($self, $account) = @_;

    die GMS::Exception::InvalidChange->new("Can't reject a change that isn't a request")
        unless $self->change_type eq 'request';

    die GMS::Exception::InvalidChange->new("Need an account to reject a change") unless $account;

    my $previous = $self->contact->active_change;
    my $ret = $self->contact->active_change ($previous->copy({ change_type => 'reject', changed_by => $account, affected_change => $self->id}));

    $self->contact->update;
    return $ret;
}

1;
