package GMS::Schema::Result::CloakChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;
use GMS::Atheme::Client;
use RPC::Atheme::Error;

use base 'DBIx::Class::Core';

=head1 NAME

GMS::Schema::Result::CloakChange

=cut

__PACKAGE__->table("cloak_changes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'cloak_changes_id_seq'

=head2 target

  data_type: 'varchar'
  size: 32
  is_foreign_key: 1
  is_nullable: 0

=head2 cloak

  data_type: 'varchar'
  size: 63
  is_nullable: 0

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
    sequence          => "cloak_changes_id_seq",
  },
  "target",
  { data_type => "varchar", size => 32, is_foreign_key => 1, is_nullable => 0 },
  "cloak",
  { data_type => "varchar", size => 63, is_nullable => 0 },
  "active_change",
  {
    data_type      => "integer",
    default_value  => -1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

__PACKAGE__->set_primary_key("id");
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
  {},
);

=head2 target

Type: belongs_to

Related object: L<GMS::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "target",
  "GMS::Schema::Result::Account",
  { id => "target" },
  { join_type => 'left' },
);

=head2 cloak_change_changes

Type: has_many

Related object: L<GMS::Schema::Result::CloakChangeChange>

=cut

__PACKAGE__->has_many(
  "cloak_change_changes",
  "GMS::Schema::Result::CloakChangeChange",
  { "foreign.cloak_change_id" => "self.id" },
  {},
);

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
    if (!$args->{cloak}) {
        push @errors, "Cloak must be provided";
        $valid = 0;
    } elsif ($args->{cloak} =~ /[^a-zA-Z0-9\-\/]/) {
        push @errors, "The cloak contains invalid characters.";
        $valid = 0;
    } elsif (length $args->{cloak} > 63) {
        push @errors, "The cloak is too long.";
        $valid = 0;
    } else {
        my $cloak = $args->{cloak};
        my ($ns, $role) = split qr|/|, $cloak;

        if (!$ns || !$role) {
            push @errors, "The cloak provided is invalid; it should be in the format of group/(role/)user";
            $valid = 0;
        }

        my $group = delete $args->{group};

        if (!$group) {
            push @errors, "You need to provide a group";
            $valid = 0;
        } elsif ( !$group->active_cloak_namespaces->find ({ 'namespace' => $ns }) ) {
                push @errors, "The namespace $ns does not belong in your Group's namespaces.";
                $valid = 0;
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
    @change_args{@change_arg_names} = delete @{$args}{@change_arg_names};
    $change_args{status} ||= 'offered';

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

    $self->change ($account, { status => "approved", change_freetext => $freetext });
    return $self->sync_to_atheme($session);
}

=head2 reject

Marks the cloak change as rejected,
by either the user or staff.

=cut

sub reject {
    my ($self, $account, $freetext) = @_;

    $self->change ($account, { status => "rejected", change_freetext => $freetext });
}

=head2 apply

Marks the cloak change as applied

=cut

sub apply {
    my ($self, $account, $freetext) = @_;

    $self->change ( $account, { status => "applied", change_freetext => $freetext } );
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
        my $uid = $cloakChange->target->id;

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
        'target_recent_cloak_changes' => \@recent,
        'status'                      => $self->active_change->status->value,
        'change_freetext'             => $self->active_change->change_freetext,
        'change_time' => $self->active_change->time
    }
}

1;
