use utf8;
package GMS::Schema::Result::ContactChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

GMS::Schema::Result::ContactChange

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<contact_changes>

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

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 email

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 change_type

  data_type: 'enum'
  extra: {custom_type_name => "change_type",list => ["create","request","approve","reject","admin","workflow_change"]}
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
  {
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "change_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "change_type",
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

=head2 active_contact

Type: might_have

Related object: L<GMS::Schema::Result::Contact>

=cut

__PACKAGE__->might_have(
  "active_contact",
  "GMS::Schema::Result::Contact",
  { "foreign.active_change" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 contact

Type: belongs_to

Related object: L<GMS::Schema::Result::Contact>

=cut

__PACKAGE__->belongs_to(
  "contact",
  "GMS::Schema::Result::Contact",
  { id => "contact_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 contact_changes

Type: has_many

Related object: L<GMS::Schema::Result::ContactChange>

=cut

__PACKAGE__->has_many(
  "contact_changes",
  "GMS::Schema::Result::ContactChange",
  { "foreign.affected_change" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-07 14:42:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eHx9UAhGmH/69waofd9Qaw
# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

# Set enum columns to use Object::Enum
__PACKAGE__->add_columns(
    '+change_type' => { is_enum => 1 }
);

use TryCatch;

use GMS::Exception;

=head1 METHODS

=head2 new

Constructor. Checks if the name and email on the given details are valid, and throws
an exception if not.

=cut

sub new {
    my ($class, $args) = @_;

    my @errors;
    my $valid=1;

    if (!$args->{name}) {
        push @errors, "Your name can't be empty.";
        $valid = 0;
    } elsif (length $args->{name} > 255) {
        push @errors, "Your name can be up to 255 characters.";
        $valid = 0;
    }
    if (!$args->{email}) {
        push @errors, "Your email can't be empty.";
        $valid = 0;
    } elsif (length $args->{email} > 255) {
        push @errors, "Your email can be up to 255 characters.";
        $valid = 0;
    }
    if (defined $args->{phone} && length $args->{phone} > 32) {
        push @errors, "Your phone can be up to 32 characters.";
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

    my $ret = $self->contact->active_change($self->copy({ change_type => 'approve', changed_by => $account, affected_change => $self->id, change_freetext => $freetext }));

    $self->contact->name($self->name);
    $self->contact->email($self->email);
    $self->contact->phone($self->phone);

    $self->contact->update;
    return $ret;
}

=head2 reject

Similar to approve but reverts the contact's previous active change with the change_type being 'reject'.

=cut

sub reject {
    my ($self, $account, $freetext) = @_;

    die GMS::Exception::InvalidChange->new("Can't reject a change that isn't a request")
        unless $self->change_type->is_request;

    die GMS::Exception::InvalidChange->new("Need an account to reject a change") unless $account;

    my $previous = $self->contact->active_change;
    my $ret = $self->contact->active_change ($previous->copy({ change_type => 'reject', changed_by => $account, affected_change => $self->id, change_freetext => $freetext }));

    $self->contact->update;
    return $ret;
}

=head2 TO_JSON

Returns a representative object for the JSON parser.

=cut

sub TO_JSON {
    my ($self) = @_;

    return {
        'id'                      => $self->id,
        'contact_account_id'      => $self->contact->account->id,
        'contact_account_name'    => $self->contact->account->accountname,
        'name'                    => $self->name,
        'contact_name'            => $self->contact->name,
        'email'                   => $self->email,
        'contact_email'           => $self->contact->email,
        'phone'                   => $self->phone,
        'contact_phone'           => $self->contact->phone,
        'changed_by_account_name' => $self->changed_by->accountname,
        'contact_account_dropped' => $self->contact->account->is_dropped,
    }
}

1;
