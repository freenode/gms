package GMS::Schema::Result::GroupChange;

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

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0

=head2 change_type

  data_type: 'enum'
  extra: {custom_type_name => "change_type",list => ["create","request","approve","reject","admin","workflow_change"]}
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
  extra: {custom_type_name => "group_status",list => ["submitted","verified","active","deleted","pending_web","pending_staff","pending_auto"]}
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
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0 },
  "change_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "change_type",
      list => ["create", "request", "approve", "reject", "admin", "workflow_change"],
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
      list => ["submitted", "verified", "active", "deleted", "pending_web", "pending_staff", "pending_auto"],
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

=head2 affected_change

Type: belongs_to

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->belongs_to(
  "affected_change",
  "GMS::Schema::Result::GroupChange",
  { id => "affected_change" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-11 20:23:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/WOEPcBCLQnrznlOq5rueQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration

# Set enum columns to use Object::Enum
__PACKAGE__->add_columns(
    '+change_type' => { is_enum => 1 },
    '+group_type' => { is_enum => 1 },
    '+status' => { is_enum => 1 },
);

use TryCatch;

use GMS::Exception;

=head1 METHODS

=head2 new

Constructor. Checks if the arguments in the change object are valid,
and throws an error if not.

=cut

sub new {
    my ($class, $args) = @_;

    my @errors;
    my $valid=1;

    if (!$args->{group_type}) {
        push @errors, "Group type cannot be empty";
        $valid = 0;
    }

    if (!$args->{status}) {
        push @errors, "Group status cannot be empty";
        $valid = 0;
    }

    if (!$args->{url}) {
        push @errors, "URL cannot be empty";
        $valid = 0;
    } else {
        if ($args->{url} !~ /^[a-zA-Z0-9:\.\/_?+-]*$/) {
            push @errors, "Group URL contains invalid characters (valid characters are a-z, A-Z, " .
                       "0-9, :_+-/)";
            $valid = 0;
        }
        if (length $args->{url} > 64) {
            push @errors, "Group URL must be up to 64 characters.";
            $valid = 0;
        }
    }

    if (!$valid) {
        die GMS::Exception::InvalidChange->new(\@errors);
    }

    return $class->next::method($args);
}

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
        unless $self->change_type->is_request;

    die GMS::Exception::InvalidChange->new("Need an account to approve a change") unless $account;

    my $ret = $self->group->active_change($self->copy({ change_type => 'approve', changed_by => $account, affected_change => $self->id, change_freetext => $freetext }));
    $self->group->update;
    return $ret;
}

=head2 reject

Similar to approve but reverts the group's previous active change with the change_type being 'reject'.

=cut

sub reject {
    my ($self, $account, $freetext) = @_;

    die GMS::Exception::InvalidChange->new("Can't reject a change that isn't a request")
        unless $self->change_type->is_request;

    die GMS::Exception::InvalidChange->new("Need an account to reject a change") unless $account;

    my $previous = $self->group->active_change;
    my $ret = $self->group->active_change ($previous->copy({ change_type => 'reject', changed_by => $account, affected_change => $self->id, change_freetext => $freetext }));

    $self->group->update;
    return $ret;
}

1;
