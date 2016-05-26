use utf8;
package GMS::Schema::Result::ChannelRequest;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

GMS::Schema::Result::ChannelRequest

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

=head1 TABLE: C<channel_requests>

=cut

__PACKAGE__->table("channel_requests");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'channel_requests_id_seq'

=head2 request_type

  data_type: 'enum'
  extra: {custom_type_name => "request_type",list => ["flags","transfer","drop"]}
  is_nullable: 0

=head2 requestor

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 channel

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 target

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 request_data

  data_type: 'text'
  is_nullable: 1

=head2 active_change

  data_type: 'integer'
  default_value: -1
  is_foreign_key: 1
  is_nullable: 0

=head2 namespace_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 status

  data_type: 'enum'
  extra: {custom_type_name => "channel_request_status",list => ["pending_staff","approved","rejected","applied","error"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "channel_requests_id_seq",
  },
  "request_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "request_type",
      list => ["flags", "transfer", "drop"],
    },
    is_nullable => 0,
  },
  "requestor",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "channel",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "target",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "request_data",
  { data_type => "text", is_nullable => 1 },
  "active_change",
  {
    data_type      => "integer",
    default_value  => -1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "namespace_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "status",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "channel_request_status",
      list => ["pending_staff", "approved", "rejected", "applied", "error"],
    },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<unique_channel_request_active_change>

=over 4

=item * L</active_change>

=back

=cut

__PACKAGE__->add_unique_constraint("unique_channel_request_active_change", ["active_change"]);

=head1 RELATIONS

=head2 active_change

Type: belongs_to

Related object: L<GMS::Schema::Result::ChannelRequestChange>

=cut

__PACKAGE__->belongs_to(
  "active_change",
  "GMS::Schema::Result::ChannelRequestChange",
  { id => "active_change" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 channel_request_changes

Type: has_many

Related object: L<GMS::Schema::Result::ChannelRequestChange>

=cut

__PACKAGE__->has_many(
  "channel_request_changes",
  "GMS::Schema::Result::ChannelRequestChange",
  { "foreign.channel_request_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 requestor

Type: belongs_to

Related object: L<GMS::Schema::Result::Contact>

=cut

__PACKAGE__->belongs_to(
  "requestor",
  "GMS::Schema::Result::Contact",
  { id => "requestor" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 target

Type: belongs_to

Related object: L<GMS::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "target",
  "GMS::Schema::Result::Account",
  { id => "target" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-09-21 14:38:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:05c4ZxDHBcKfmuNkAMpUlw
# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->load_components ("InflateColumn::Object::Enum");

# Set enum columns to use Object::Enum
__PACKAGE__->add_columns(
    '+request_type' => { is_enum => 1 }
);

use TryCatch;
use GMS::Atheme::Client;

=head1 METHODS

=head2 new

Constructor. A ChannelRequest is constructed with all of the required fields from both
ChannelRequest and ChannelRequestChange, and will implicitly create a change record for
the channel request change with its initial state.

Valid arguments are changed_by ( the person requesting the change ),
requestor, request_type, channel, target and the optional
request_data which can hold additional required information.
Optionally, 'status' can be provided, which defaults to pending_staff

=cut

sub new {
    my ($class, $args) = @_;
    my @errors;
    my $valid=1;

    if (!$args->{requestor}) {
        push @errors, "Requestor must be specified";
        $valid = 0;
    }
    if (!$args->{request_type}) {
        push @errors, "Request Type must be provided";
        $valid = 0;
    }
    if (!$args->{channel}) {
        push @errors, "Channel must be provided";
        $valid = 0;
    }
    if (!$args->{namespace}) {
        push @errors, "Namespace must be provided";
        $valid = 0;
    }
    if (!$args->{group}) {
        push @errors, "Group must be provided";
        $valid = 0;
    }

    if ($valid) {
        my $namespace_name = delete $args->{namespace};
        my $group = delete $args->{group};
        my $channel = $args->{channel};

        my $namespace = $group->active_channel_namespaces->find ({ 'namespace' => $namespace_name });

        if (!$namespace) {
            push @errors, "This namespace does not belong in your Group's namespaces.";
            $valid = 0;
        } else {
            $args->{namespace_id} = $namespace->id;
        }

        if ( $channel ne "#$namespace_name" && index($channel, "#$namespace_name-") != 0) {
            push @errors, "This channel does not belong in that namespace.";
            $valid = 0;
        }
    }

    if ( !$args->{target} && $args->{request_type} && $args->{request_type} eq 'transfer' ) {
        push @errors, "Target must be provided";
        $valid = 0;
    }
    if (!$args->{changed_by}) {
        push @errors, "Changed by must be provided";
        $valid = 0;
    }

    if (!$valid) {
        die GMS::Exception::InvalidChannelRequest->new(\@errors);
    }

    my @change_arg_names = (
        'changed_by',
        'status',
    );

    $args->{status} ||= 'pending_staff';

    my %change_args;
    @change_args{@change_arg_names} = @{$args}{@change_arg_names};

    delete $args->{changed_by};

    $args->{channel_request_changes} = [ \%change_args ];

    return $class->next::method($args);
}

=head2 insert

Overloaded to support the implicit ChannelRequestChange creation.

=cut

sub insert {
    my ($self) = @_;
    my $ret;

    my $next_method = $self->next::can;
    # Can't put this in the creation args, as we don't know the active change id
    # until the change has been created, and we can't create the change without knowing
    # the ChannelRequestChange id.

    $self->result_source->schema->txn_do( sub {
        $self->result_source->storage->with_deferred_fk_checks(sub {
                $ret = $self->$next_method();
                $self->active_change($self->channel_request_changes->single);
                $self->update;
            });
    });

    return $ret;
}

=head2 change

    $ChannelRequest->change($account, \%args);

Creates a related ChannelRequestChange with the modifications specified in %args.
Unchanged fields are populated based on the ChannelRequest's current state.

=cut

sub change {
    my ($self, $account, $args) = @_;

    my $active_change = $self->active_change;

    my %change_args = (
        changed_by => $account,
        status => $args->{status} || $active_change->status,
        change_freetext => $args->{change_freetext}
    );

    my $ret = $self->add_to_channel_request_changes(\%change_args);
    $self->active_change($ret);

    $self->status($args->{status});

    $self->update;
    return $ret;
}

=head2 approve

Marks the channel request as approved by staff and attempts to apply the changes
on Atheme

=cut

sub approve {
    my ($self, $session, $account, $freetext) = @_;

    if ( $self->status->is_pending_staff || $self->status->is_error ) {
        $self->change ($account, { status => "approved", change_freetext => $freetext });
        return $self->sync_to_atheme($session);
    } else {
        die GMS::Exception->new ("Can't approve a change not pending approval");
    }

}


=head2 reject

Marks the channel request as rejected by staff.

=cut

sub reject {
    my ($self, $account, $freetext) = @_;

    if ( $self->status->is_pending_staff || $self->status->is_error ) {
        $self->change ($account, { status => "rejected", change_freetext => $freetext });
    } else {
        die GMS::Exception->new ("Can't reject a change not pending approval");
    }
}

=head2 apply

Marks the channel request as applied

=cut

sub apply {
    my ($self, $account, $freetext) = @_;

    if ( $self->status->is_error || $self->status->is_approved ) {
        $self->change ( $account, { status => "applied", change_freetext => $freetext } );
    } else {
        die GMS::Exception->new ("Can't apply a change not pending application");
    }
}

=head2 sync_to_atheme

Attempts to apply any changes that have been approved by staff but not yet
applied in Atheme

=cut

sub sync_to_atheme {
    my ($self, $session) = @_;

    my $schema = $self->result_source->schema;

    my $change_rs = $schema->resultset('ChannelRequest');
    my $contact_rs = $schema->resultset ('Contact');
    my $account_rs = $schema->resultset ('Account');

    my @unapplied = $change_rs->search_unapplied;

    my $client;

    try {
        $client = GMS::Atheme::Client->new ($session);
    }
    catch (RPC::Atheme::Error $e) {
        foreach my $channelRequest (@unapplied) {
            $channelRequest->change (
                $channelRequest->active_change->changed_by,
                { status => "error", change_freetext => $e }
            );
        }

        return $e;
    }

    my $error = undef;

    foreach my $channelRequest (@unapplied) {
        my $type = $channelRequest->request_type;
        my $channel = $channelRequest->channel;
        my $contact_id = $channelRequest->requestor->id;

        my $contact = $contact_rs->find({ 'id' => $contact_id });
        my $requestor_id = $contact->account->id;

        my $request_type = $channelRequest->request_type;

        try {
            if ( $request_type->is_transfer) {
                my $target = $channelRequest->target;

                $client->take_over ( $channel, $target->id, $requestor_id );
            } elsif ( $request_type->is_drop ) {
                $client->drop ( $channel, $requestor_id );
            }

            $channelRequest->apply (
                $channelRequest->active_change->changed_by
            );
        }
        catch (RPC::Atheme::Error $e) {
            $channelRequest->change (
                $channelRequest->active_change->changed_by,
                { status => "error", change_freetext => $e }
            );

            $error = $e;
        }
    }

    return $error;
}

# Set enum columns to use Object::Enum
__PACKAGE__->add_columns(
    '+status' => { is_enum => 1 },
);

=head2 TO_JSON

Returns a representative object for the JSON parser.

=cut

sub TO_JSON {
    my ($self) = @_;

    my $target_name    = undef;
    my $target_dropped = undef;
    my $target_id      = undef;

    if ( $self->target ) {
        $target_name     = $self->target->accountname;
        $target_dropped  = $self->target->is_dropped;
        $target_id       = $self->target->id;
    }

    return {
        'id'                => $self->id,
        'request_type'      => $self->request_type->value,
        'channel'           => $self->channel,
        'request_data'      => $self->request_data,
        'status'            => $self->active_change->status->value,
        'change_freetext'   => $self->active_change->change_freetext,
        'requestor_name'    => $self->requestor->account->accountname,
        'requestor_id'      => $self->requestor->account->id,
        'requestor_dropped' => $self->requestor->account->is_dropped,
        'target_id'         => $target_id,
        'target_name'       => $target_name,
        'target_dropped'    => $target_dropped,
        'namespace'         => $self->namespace->namespace,
        'group_name'        => $self->namespace->group->group_name,
        'group_url'         => $self->namespace->group->url,
    }
}
1;
