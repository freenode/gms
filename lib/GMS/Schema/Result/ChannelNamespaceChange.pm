use utf8;
package GMS::Schema::Result::ChannelNamespaceChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

GMS::Schema::Result::ChannelNamespaceChange

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Object::Enum>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head1 TABLE: C<channel_namespace_changes>

=cut

__PACKAGE__->table("channel_namespace_changes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'channel_namespace_changes_id_seq'

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 namespace_id

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
  extra: {custom_type_name => "channel_namespace_changes_change_type_type",list => ["create","request","approve","reject","admin","workflow_change"]}
  is_nullable: 0

=head2 status

  data_type: 'enum'
  extra: {custom_type_name => "channel_namespace_changes_status_type",list => ["active","deleted","pending_staff"]}
  is_nullable: 0

=head2 affected_change

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

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
    sequence          => "channel_namespace_changes_id_seq",
  },
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "namespace_id",
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
      custom_type_name => "channel_namespace_changes_change_type_type",
      list => [
        "create",
        "request",
        "approve",
        "reject",
        "admin",
        "workflow_change",
      ],
    },
    is_nullable => 0,
  },
  "status",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "channel_namespace_changes_status_type",
      list => ["active", "deleted", "pending_staff"],
    },
    is_nullable => 0,
  },
  "affected_change",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "change_freetext",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 affected_change

Type: belongs_to

Related object: L<GMS::Schema::Result::ChannelNamespaceChange>

=cut

__PACKAGE__->belongs_to(
  "affected_change",
  "GMS::Schema::Result::ChannelNamespaceChange",
  { id => "affected_change" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 changed_by

Type: belongs_to

Related object: L<GMS::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "changed_by",
  "GMS::Schema::Result::Account",
  { id => "changed_by" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 channel_namespace

Type: might_have

Related object: L<GMS::Schema::Result::ChannelNamespace>

=cut

__PACKAGE__->might_have(
  "channel_namespace",
  "GMS::Schema::Result::ChannelNamespace",
  { "foreign.active_change" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 channel_namespace_changes

Type: has_many

Related object: L<GMS::Schema::Result::ChannelNamespaceChange>

=cut

__PACKAGE__->has_many(
  "channel_namespace_changes",
  "GMS::Schema::Result::ChannelNamespaceChange",
  { "foreign.affected_change" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 group

Type: belongs_to

Related object: L<GMS::Schema::Result::Group>

=cut

__PACKAGE__->belongs_to(
  "group",
  "GMS::Schema::Result::Group",
  { id => "group_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 namespace

Type: belongs_to

Related object: L<GMS::Schema::Result::ChannelNamespace>

=cut

__PACKAGE__->belongs_to(
  "namespace",
  "GMS::Schema::Result::ChannelNamespace",
  { id => "namespace_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-01 18:48:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fXHlNya4jTclDPIISd5PKA
# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head2 namespace_where_active

Type: has_one

Related object: L<GMS::Schema::Result::ChannelNamespace>

=cut

__PACKAGE__->has_one(
  "namespace_where_active" =>
  "GMS::Schema::Result::ChannelNamespace" => "active_change"
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

    if (!$args->{group_id}) {
        push @errors, "Group id cannot be empty";
        $valid = 0;
    }

    if (!$args->{status}) {
        push @errors, "Namespace status cannot be empty";
        $valid = 0;
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

    my $ret = $self->namespace->active_change($self->copy({ change_type => 'approve', changed_by => $account, affected_change => $self->id, change_freetext => $freetext }));

    $self->namespace->status($self->status);
    $self->namespace->group_id($self->group_id);

    $self->namespace->update;
    return $ret;
}

=head2 reject

Similar to approve but reverts the channel namespace's previous active change with the change_type being 'reject'.

=cut

sub reject {
    my ($self, $account, $freetext) = @_;

    die GMS::Exception::InvalidChange->new("Can't reject a change that isn't a request")
        unless $self->change_type->is_request;

    die GMS::Exception::InvalidChange->new("Need an account to reject a change") unless $account;

    my $previous = $self->namespace->active_change;
    my $ret = $self->namespace->active_change ($previous->copy({ change_type => 'reject', changed_by => $account, affected_change => $self->id, change_freetext => $freetext }));

    $self->namespace->update;
    return $ret;
}

__PACKAGE__->add_columns(
    '+change_type' => { is_enum => 1 },
    '+status' => { is_enum => 1 },
);

=head2 TO_JSON

Returns a representative object for the JSON parser.

=cut

sub TO_JSON {
    my ($self) = @_;

    return {
        'id'                      => $self->id,
        'namespace_name'          => $self->namespace->namespace,
        'status'                  => $self->status->value,
        'namespace_status'        => $self->namespace->active_change->status->value,
        'changed_by_account_name' => $self->changed_by->accountname,
        'group'                   =>
        {
            'id'    => $self->group->id,
            'name'  => $self->group->group_name
        },
        'namespace_group'        =>
        {
            'id'    => $self->namespace->group->id,
            'name'  => $self->namespace->group->group_name
        }
    }
}

1;
