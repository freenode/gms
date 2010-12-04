package GMS::Schema::Result::Group;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

GMS::Schema::Result::Group

=cut

__PACKAGE__->table("groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'groups_id_seq'

=head2 group_name

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 verify_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 verify_token

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 submitted

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 verify_auto

  data_type: 'boolean'
  is_nullable: 1

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
    sequence          => "groups_id_seq",
  },
  "group_name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "verify_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "verify_token",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "submitted",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "verify_auto",
  { data_type => "boolean", is_nullable => 1 },
  "active_change",
  {
    data_type      => "integer",
    default_value  => -1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("unique_verify", ["verify_url"]);
__PACKAGE__->add_unique_constraint("unique_name", ["group_name"]);

=head1 RELATIONS

=head2 channel_namespaces

Type: has_many

Related object: L<GMS::Schema::Result::ChannelNamespace>

=cut

__PACKAGE__->has_many(
  "channel_namespaces",
  "GMS::Schema::Result::ChannelNamespace",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 cloak_namespaces

Type: has_many

Related object: L<GMS::Schema::Result::CloakNamespace>

=cut

__PACKAGE__->has_many(
  "cloak_namespaces",
  "GMS::Schema::Result::CloakNamespace",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 group_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->has_many(
  "group_changes",
  "GMS::Schema::Result::GroupChange",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 group_contacts

Type: has_many

Related object: L<GMS::Schema::Result::GroupContact>

=cut

__PACKAGE__->has_many(
  "group_contacts",
  "GMS::Schema::Result::GroupContact",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 active_change

Type: belongs_to

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->belongs_to(
  "active_change",
  "GMS::Schema::Result::GroupChange",
  { id => "active_change" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-13 23:56:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zjq2zlJ2apQumOBn3BaVVw

# Pseudo-relations not added by Schema::Loader
__PACKAGE__->many_to_many(contacts => 'group_contacts', 'contact');

use TryCatch;
use String::Random qw/random_string/;

=head1 METHODS

=head2 new

Constructor. A Group is constructed with all of the required fields from both
Group and GroupChange, and will implicitly create a 'create' change for the
group with its initial state.

The group name, type, and URL must be specified. Address is optional. All other
fields will be populated automatically.

=cut

sub new {
    my $class = shift;
    my $args = shift;

    my @errors;
    my $valid=1;

    if (!$args->{group_type}) {
        push @errors, "Group type must be specified";
        $valid = 0;
    }
    if (!$args->{group_name}) {
        push @errors, "Group name must be provided";
        $valid = 0;
    }
    if ($args->{group_name} !~ /^[A-Za-z0-9 _\.-]*$/) {
        push @errors, "Group name must contain only alphanumeric characters, space, " .
                       "underscores, hyphens and dots.";
        $valid = 0;
    }
    if (!$args->{url}) {
        push @errors, "Group URL must be provided";
        $valid = 0;
    }
    if ($args->{url} !~ /^[a-zA-Z0-9:\.\/_?+-]*$/) {
        push @errors, "Group URL contains invalid characters (valid characters are a-z, A-Z, " .
                       "0-9, :_+-/)";
        $valid = 0;
    }

    if (!$valid) {
        die GMS::Exception::InvalidGroup->new(\@errors);
    }

    $args->{verify_url} = $args->{url}."/".random_string("cccccccc").".txt";
    $args->{verify_token} = random_string("cccccccccccc");

    my @change_arg_names = (
        'group_type',
        'url',
        'address',
    );
    my %change_args;
    @change_args{@change_arg_names} = delete @{$args}{@change_arg_names};
    $change_args{status} = 'submitted';
    $change_args{change_type} = 'create';
    $change_args{changed_by} = delete $args->{account};

    $args->{group_changes} = [ \%change_args ];

    return $class->next::method($args);
}

=head2 insert

Overloaded to support the implicit GroupChange creation.

=cut

sub insert {
    my ($self) = @_;
    my $ret;

    my $next_method = $self->next::can;

    # Can't put this in the creation args, as we don't know the active change id
    # until the change has been created, and we can't create the change without knowing
    # the group id.
    $self->result_source->storage->with_deferred_fk_checks(sub {
            $ret = $self->$next_method();
            $self->active_change($self->group_changes->single);
            $self->update;
        });

    return $ret;
}

=head2 change

    $group->change($account, $changetype, \%args);

Creates a related GroupChange with the modifications specified in %args.
Unchanged fields are populated based on the group's current state.

=cut

sub change {
    my ($self, $account, $change_type, $args) = @_;

    my $active_change = $self->active_change;

    my %change_args = (
        changed_by => $account,
        change_type => $change_type,
        group_type => $args->{group_type} || $active_change->group_type,
        url => $args->{url} || $active_change->url,
        address => $args->{address} || $active_change->address,
        status => $args->{status} || $active_change->status
    );

    my $ret = $self->active_change($self->add_to_group_changes(\%change_args));
    $self->update;
    return $ret;
}


#sub use_automatic_verification {
#    my ($name, $url) = @_;
#    $url =~ tr/A-Z/a-z/;
#    $url =~ s!http://!!;
#    $url =~ s!www\.!!;
#    $url =~ s!\.[a-z]+/?!!;
#    $name =~ tr/A-Z/a-z/;
#    $name =~ s/\W//g;
#
#    return $name eq $url;
#}
#
#sub simple_url {
#    my ($self) = @_;
#    my $url = $self->url;
#    $url =~ tr/A-Z/a-z/;
#
#    if ($url !~ m!^[a-z]+://!) {
#        $url = "http://" . $url;
#    }
#
#    $url =~ s/\/$//;
#    return $url;
#}

=head2 status

Returns the current status of the group, based on the active change.

=cut

sub status {
    my ($self) = @_;

    return $self->active_change->status;
}

=head2 verify

    $group->verify($verifiedby);

Marks the group, which must be pending verification, as verified.

=cut

sub verify {
    my ($self, $account) = @_;
    if ($self->status ne 'submitted') {
        die GMS::Exception->new("Can't verify a group that isn't pending verification");
    }
    $self->change( $account, 'admin', { status => 'verified' } );
    $self->update;
}

=head2 approve

    $group->approve($approvedby);

Marks the group, which must be pending verification or approval, as approved.
Takes one argument, the account which approved it.

=cut

sub approve {
    my ($self, $account) = @_;
    if ($self->status ne 'verified' && $self->status ne 'submitted') {
        die GMS::Exception->new("Can't approve a group that isn't verified or "
            . "pending verification");
    }
    $self->change( $account, 'admin', { status => 'active' } );
}

=head2 reject

Marks the group, which must not be approved, as rejected. The only argument is
the account rejecting it.

=cut

sub reject {
    my ($self, $account) = @_;
    if ($self->status ne 'verified' && $self->status ne 'submitted') {
        die GMS::Exception->new("Can't reject a group not pending approval");
    }
    $self->change( $account, 'admin', { status => 'deleted' } );
}


# You can replace this text with custom content, and it will be preserved on regeneration
1;
