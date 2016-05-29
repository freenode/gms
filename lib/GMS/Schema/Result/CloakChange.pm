use utf8;
package GMS::Schema::Result::CloakChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

GMS::Schema::Result::CloakChange

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

=head1 TABLE: C<cloak_changes>

=cut

__PACKAGE__->table("cloak_changes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'cloak_changes_id_seq'

=head2 target

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 requestor

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 cloak

  data_type: 'varchar'
  is_nullable: 0
  size: 63

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
  extra: {custom_type_name => "cloak_change_status",list => ["offered","accepted","approved","rejected","applied","error"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "cloak_changes_id_seq",
  },
  "target",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "requestor",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "cloak",
  { data_type => "varchar", is_nullable => 0, size => 63 },
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
      custom_type_name => "cloak_change_status",
      list => ["offered", "accepted", "approved", "rejected", "applied", "error"],
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

=head2 C<unique_cloak_active_change>

=over 4

=item * L</active_change>

=back

=cut

__PACKAGE__->add_unique_constraint("unique_cloak_active_change", ["active_change"]);

=head1 RELATIONS

=head2 active_change

Type: belongs_to

Related object: L<GMS::Schema::Result::CloakChangeChange>

=cut

__PACKAGE__->belongs_to(
  "active_change",
  "GMS::Schema::Result::CloakChangeChange",
  { id => "active_change" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 cloak_change_changes

Type: has_many

Related object: L<GMS::Schema::Result::CloakChangeChange>

=cut

__PACKAGE__->has_many(
  "cloak_change_changes",
  "GMS::Schema::Result::CloakChangeChange",
  { "foreign.cloak_change_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 namespace

Type: belongs_to

Related object: L<GMS::Schema::Result::CloakNamespace>

=cut

__PACKAGE__->belongs_to(
  "namespace",
  "GMS::Schema::Result::CloakNamespace",
  { id => "namespace_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 requestor

Type: belongs_to

Related object: L<GMS::Schema::Result::Contact>

=cut

__PACKAGE__->belongs_to(
  "requestor",
  "GMS::Schema::Result::Account",
  { id => "requestor" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 target

Type: belongs_to

Related object: L<GMS::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "target",
  "GMS::Schema::Result::Account",
  { id => "target" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-09-28 18:31:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:G9/kg4CYO++6lZ4y20R7Wg
# You can replace this text with custom code or comments, and it will be preserved on regeneration

use TryCatch;

=head1 METHODS

=head2 new

Constructor. A CloakChange is constructed with all of the required fields from both
CloakChange and CloakChangeChange, and will implicitly create a change record for
the cloak change with its initial state.

The only argument is status, which defaults to 'offered'

=cut

sub new {
    my $class = shift;
    my $args = shift;

    my @errors;
    my $valid=1;

    if (!$args->{target}) {
        push @errors, "target must be specified";
        $valid = 0;
    }

    if (!$args->{requestor}) {
        push @errors, "requestor must be specified";
        $valid = 0;
    }

    if (!$args->{cloak}) {
        push @errors, "Cloak must be provided";
        $valid = 0;
    } else {
        my $cloak = $args->{cloak};
        my (@parts) = split qr|/|, $cloak;
        my (@ns_and_role) = split qr|/|, $cloak, 2;

        my ($ns, $role) = @ns_and_role;

        if(!$role) {
            push @errors, "(Role/)user must be provided";
            $valid = 0;
        } elsif(!$ns) {
            push @errors, "Cloak namespace must be provided";
            $valid = 0;
        } elsif ($role =~ /[^a-zA-Z0-9\-\/]/) {
            push @errors, "The role/user contains invalid characters. Only alphanumeric characters, dash and slash are allowed.";
            $valid = 0;
        } elsif (length $args->{cloak} > 63) {
            push @errors, "The cloak is too long.";
            $valid = 0;
        } elsif ($role =~ qr|/$|) {
            push @errors, "The cloak cannot end with a slash.";
            $valid = 0;
        } elsif ($parts[-1] =~ /^[0-9]/) {
            push @errors, "The cloak provided looks like a CIDR mask.";
            $valid = 0;
        }

        my $group = delete $args->{group};

        if (!$group) {
            push @errors, "You need to provide a group";
            $valid = 0;
        } else {
            my $namespace = $group->active_cloak_namespaces->find ({ 'namespace' => $ns });

            if (!$namespace) {
                push @errors, "The namespace $ns does not belong in your Group's namespaces.";
                $valid = 0;
            } else {
                $args->{namespace_id} = $namespace->id;
            }
        }
    }

    if (!$args->{changed_by}) {
        push @errors, "Changed by must be provided";
        $valid = 0;
    }

    if (!$valid) {
        die GMS::Exception::InvalidCloakChange->new(\@errors);
    }

    my @change_arg_names = (
        'changed_by',
        'status',
    );

    my %change_args;

    $args->{status} ||= 'offered';

    @change_args{@change_arg_names} = @{$args}{@change_arg_names};

    delete $args->{changed_by};

    $args->{cloak_change_changes} = [ \%change_args ];

    return $class->next::method($args);
}

=head2 insert

Overloaded to support the implicit CloakChangeChange creation.

=cut

sub insert {
    my ($self) = @_;
    my $ret;

    my $next_method = $self->next::can;
    # Can't put this in the creation args, as we don't know the active change id
    # until the change has been created, and we can't create the change without knowing
    # the cloakChange id.

    $self->result_source->schema->txn_do( sub {
        $self->result_source->storage->with_deferred_fk_checks(sub {
                $ret = $self->$next_method();
                $self->active_change($self->cloak_change_changes->single);
                $self->update;
            });
    });

    return $ret;
}

=head2 change

    $cloakChange->change($account, \%args);

Creates a related CloakChangeChange with the modifications specified in %args.
Unchanged fields are populated based on the CloakChange's current state.

=cut

sub change {
    my ($self, $account, $args) = @_;

    my $active_change = $self->active_change;

    my %change_args = (
        changed_by => $account,
        status => $args->{status} || $active_change->status,
        change_freetext => $args->{change_freetext}
    );

    my $ret = $self->add_to_cloak_change_changes(\%change_args);
    $self->active_change($ret);

    $self->status($args->{status});

    $self->update;
    return $ret;
}


=head2 accept

Marks the cloak change as accepted from the user.

=cut

sub accept {
    my ($self, $account) = @_;

    $self->change ($account, { status => "accepted" });
}

=head2 approve

Marks the cloak change as approved by staff, and cloaks the user.

=cut

sub approve {
    my ($self, $session, $account, $freetext) = @_;

    if ( $self->status->is_accepted || $self->status->is_error ) {
        $self->change ($account, { status => "approved", change_freetext => $freetext });
        return $self->sync_to_atheme($session);
    } else {
        die GMS::Exception->new ("Can't approve a change not pending approval");
    }
}

=head2 reject

Marks the cloak change as rejected,
by either the user or staff.

=cut

sub reject {
    my ($self, $account, $freetext) = @_;

    if ( $self->status->is_offered || $self->status->is_accepted || $self->status->is_error ) {
        $self->change ($account, { status => "rejected", change_freetext => $freetext });
    } else {
        die GMS::Exception->new ("Can't reject a change not pending approval");
    }
}

=head2 apply

Marks the cloak change as applied

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

    my $change_rs = $self->result_source->schema->resultset('CloakChange');
    my @unapplied = $change_rs->search_unapplied;

    my $client;

    try {
        $client = GMS::Atheme::Client->new ($session);
    }
    catch (RPC::Atheme::Error $e) {
        foreach my $cloakChange (@unapplied) {
            $cloakChange->change (
                $cloakChange->active_change->changed_by,
                { status => "error", change_freetext => $e }
            );
        }

        return $e;
    }

    my $error = undef;

    foreach my $cloakChange (@unapplied) {
        my $cloak = $cloakChange->cloak;
        my $uid = $cloakChange->target->uuid;

        try {
            $client->cloak ( $uid, $cloak );
            $cloakChange->apply (
                $cloakChange->active_change->changed_by
            );
        }
        catch (RPC::Atheme::Error $e) {
            $cloakChange->change (
                $cloakChange->active_change->changed_by,
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

    my @changes = $self->target->recent_cloak_changes->all;
    my @recent;

    #We can't directly use @changes, as it'll cause an infinite recursion,
    #but we don't want all the change data anyway.
    foreach my $change (@changes) {
        push @recent, {
            'cloak'       => $change->cloak,
            'change_time' => $change->active_change->time,
        }
    }

    return {
        'id'                          => $self->id,
        'cloak'                       => $self->cloak,
        'target_id'                   => $self->target->id,
        'target_name'                 => $self->target->accountname,
        'target_dropped'              => $self->target->is_dropped,
        'target_recent_cloak_changes' => \@recent,
        'status'                      => $self->active_change->status->value,
        'change_freetext'             => $self->active_change->change_freetext,
        'change_time'                 => $self->active_change->time,
        'group_name'                  => $self->namespace->group->group_name,
        'group_url'                   => $self->namespace->group->url,
        'namespace'                   => $self->namespace->namespace,
    }
}

1;
