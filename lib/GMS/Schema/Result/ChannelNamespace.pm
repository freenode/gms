package GMS::Schema::Result::ChannelNamespace;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head1 NAME

GMS::Schema::Result::ChannelNamespace

=cut

__PACKAGE__->table("channel_namespaces");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'channel_namespaces_id_seq'

=head2 namespace

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 active_change

  data_type: 'integer'
  default_value: -1
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "channel_namespaces_id_seq",
  },
  "namespace",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "active_change",
  {
    data_type      => "integer",
    default_value  => -1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("channel_namespaces_unique_active_change", ["active_change"]);
__PACKAGE__->add_unique_constraint("unique_channel_ns", ["namespace"]);

=head1 RELATIONS

=head2 channel_namespace_changes

Type: has_many

Related object: L<GMS::Schema::Result::ChannelNamespaceChange>

=cut

__PACKAGE__->has_many(
  "channel_namespace_changes",
  "GMS::Schema::Result::ChannelNamespaceChange",
  { "foreign.namespace_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 active_change

Type: belongs_to

Related object: L<GMS::Schema::Result::ChannelNamespaceChange>

=cut

__PACKAGE__->belongs_to(
  "active_change",
  "GMS::Schema::Result::ChannelNamespaceChange",
  { id => "active_change" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-01-30 15:56:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wun0TkBA5rpF91zVGyJ93Q

# You can replace this text with custom code or comments, and it will be preserved on regeneration

use TryCatch;
use GMS::Exception;

=head1 METHODS

=head2 new

Constructor. A ChannelNamespace is constructed with all the fields required both for itself
and its initial ChannelNamespaceChange, and will implicitly create a 'create' change.

=cut

sub new {
    my ($class, $args) = @_;

    my @change_arg_names = (
        'group_id',
        'status',
    );

    my %change_args;

    @change_args{@change_arg_names} = delete @{$args}{@change_arg_names};
    $change_args{status} ||= 'pending-staff';
    $change_args{change_type} = 'create';
    $change_args{changed_by} = delete $args->{account};
    $change_args{change_freetext} = delete $args->{freetext};

    $args->{channel_namespace_changes} = [ \%change_args ];

    return $class->next::method($args);
}

=head2 insert

Overloaded to support the implicit ChannelNamespaceChange creation

=cut

sub insert {
    my ($self) = @_;
    my $ret;

    my $next_method = $self->next::can;

    $self->result_source->storage->with_deferred_fk_checks(sub {
            $ret = $self->$next_method();
            $self->active_change($self->channel_namespace_changes->single);

            $self->update;
        });

    return $ret;
}

=head2 change

Creates a related ChannelNamespaceChange with the modifications specified in %args.
Unchanged fields are populated based on the namespace's current state.

=cut

sub change {
    my ($self, $account, $change_type, $args) = @_;

    my $active_change = $self->active_change;

    my %change_args = (
        changed_by => $account,
        change_type => $change_type,
        group_id => $args->{group_id} || $active_change->group_id,
        status => $args->{status} || $active_change->status,
        change_freetext => $args->{change_freetext}
    );

    my $ret = $self->add_to_channel_namespace_changes(\%change_args);
    $self->active_change($ret) if $change_type ne 'request';
    $self->update;
    return $ret;
}

=head2 approve

    $namespace->approve($approvedby, $freetext);

Marks the namespace, which must be pending approval, as approved.
Takes two arguments, the account which approved it and optional freetext about
the approval.

=cut

sub approve {
    my ($self, $account, $freetext) = @_;

    if ($self->status ne 'pending-staff') {
        die GMS::Exception->new("Can't approve a namespace that isn't pending approval");
    }

    $self->change( $account, 'admin', { status => 'active', 'change_freetext' => $freetext } );
}

=head2 reject

Marks the namespace, which must not be approved, as rejected. Takes two arguments,
the account which rejected it and optional freetext about the rejection.

=cut

sub reject {
    my ($self, $account, $freetext) = @_;

    if ($self->status ne 'pending-staff') {
        die GMS::Exception->new("Can't reject a namespace not pending approval");
    }

    $self->change( $account, 'admin', { status => 'deleted', 'change_freetext' => $freetext } );
}

=head2 status

Returns the current status of the namespace, based on the active change.

=cut

sub status {
    my ($self) = @_;
    return $self->active_change->status;
}

=head2 group

Returns the namespace's current group, based on the active change.

=cut

sub group {
    my ($self) = @_;
    return $self->active_change->group;
}

1;
