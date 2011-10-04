package GMS::Schema::Result::GroupContact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head1 NAME

GMS::Schema::Result::GroupContact

=cut

__PACKAGE__->table("group_contacts");

=head1 ACCESSORS

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 contact_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 active_change

  data_type: 'integer'
  default_value: -1
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "contact_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "active_change",
  {
    data_type      => "integer",
    default_value  => -1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("group_id", "contact_id");
__PACKAGE__->add_unique_constraint("group_contacts_unique_active_change", ["active_change"]);

=head1 RELATIONS

=head2 group_contact_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupContactChange>

=cut

__PACKAGE__->has_many(
  "group_contact_changes",
  "GMS::Schema::Result::GroupContactChange",
  {
    "foreign.contact_id" => "self.contact_id",
    "foreign.group_id"   => "self.group_id",
  },
  {},
);

=head2 group

Type: belongs_to

Related object: L<GMS::Schema::Result::Group>

=cut

__PACKAGE__->belongs_to("group", "GMS::Schema::Result::Group", { id => "group_id" }, {});

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

=head2 active_change

Type: belongs_to

Related object: L<GMS::Schema::Result::GroupContactChange>

=cut

__PACKAGE__->belongs_to(
  "active_change",
  "GMS::Schema::Result::GroupContactChange",
  { id => "active_change" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-08 18:39:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7y+Su1JqNCS+2e+Gc7A5Hw


# You can replace this text with custom content, and it will be preserved on regeneration

use TryCatch;

use GMS::Exception;

=head1 METHODS

=head2 new

Constructor. A GroupContact is constructed with all the fields required both for itself
and its initial GroupContactChange, and will implicitly create a 'create' change.

=cut

sub new {

    my ($class, $args) = @_;
    my @change_arg_names = (
        'primary',
        'status',
    );
    my %change_args;
    @change_args{@change_arg_names} = delete @{$args}{@change_arg_names};
    $change_args{status} ||= 'invited';
    $change_args{change_type} = 'create';
    $change_args{primary} ||= 0;
    $change_args{changed_by} = delete $args->{account};

    $args->{group_contact_changes} = [ \%change_args ];

    return $class->next::method($args);
}

=head2 insert

Overloaded to support the implicit GroupContactChange creation

=cut

sub insert {
    my ($self) = @_;
    my $ret;

    my $next_method = $self->next::can;

    $self->result_source->storage->with_deferred_fk_checks(sub {
            $ret = $self->$next_method();
            $self->active_change($self->group_contact_changes->single);
            $self->update;
        });

    return $ret;
}

=head2 change

    $group_contact->change($account, $changetype, \%args);

Creates a related GroupChange with the modifications specified in %args.
Unchanged fields are populated based on the group's current state.

=cut

sub change {
    my ($self, $account, $change_type, $args) = @_;

    my $active_change = $self->active_change;

    my %change_args = (
        changed_by => $account,
        change_type => $change_type,
        status => $args->{status} || $active_change->status,
        primary => $args->{primary} || $active_change->primary,
    );

    my $ret = $self->add_to_group_contact_changes(\%change_args);
    $self->active_change($ret) if $change_type ne 'request';
    $self->update;
    return $ret;
}

=head2 approve_change

    $group_contact->approve_change($change, $approving_account);

If the given change is a request, then create and return a new change identical
to it except for the type, which will be 'approve', and the user, which must be
provided.  The effect is to approve the given request.

If the given change isn't a request, calling this is an error.

=cut

sub approve_change {
    my ($self, $change, $account) = @_;

    die GMS::Exception::InvalidChange->new("Can't approve a change that isn't a request")
        unless $change->change_type eq 'request';

    die GMS::Exception::InvalidChange->new("Need an account to approve a change") unless $account;

    my $ret = $self->active_change($change->copy({ change_type => 'approve', changed_by => $account}));
    $self->update;
    return $ret;
}

1;
