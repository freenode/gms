package GMS::Schema::Result::CloakChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

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

=head2 contact_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 cloak

  data_type: 'varchar'
  size: 63
  is_nullable: 0

=cut

=head2 time

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 changed_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 offered

  data_type: 'timestamp'
  default_value: '\NULL'
  is_nullable: 1

=cut

=head2 accepted

  data_type: 'timestamp'
  default_value: \'NULL'
  is_nullable: 1

=cut

=head2 approved

  data_type: 'timestamp'
  default_value: \'NULL'
  is_nullable: 1

=cut

=head2 rejected

  data_type: 'tmestamp'
  default_value: \'NULL'
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
    sequence          => "cloak_changes_id_seq",
  },
  "contact_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "cloak",
  { data_type => "varchar", size => 63, is_nullable => 0 },
  "time",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "changed_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "offered",
  { data_type => "timestamp", default_value => \"NULL", is_nullable => 1},
  "accepted",
  { data_type => "timestamp", default_value => \"NULL", is_nullable => 1},
  "approved",
  { data_type => "timestamp", default_value => \"NULL", is_nullable => 1},
  "rejected",
  { data_type => "timestamp", default_value => \"NULL", is_nullable => 1},
  "change_freetext",
  { data_type => "text", is_nullable => 1},
);

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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

use TryCatch;

=head1 METHODS

=head2 accept

Marks the cloak change as accepted from the user.

=cut

sub accept {
    my ($self) = @_;

    $self->accepted (\"NOW()");
    $self->update;
}

=head2 approve

Marks the cloak change as approved by staff, and cloaks the user.

=cut

sub approve {
    my ($self, $c, $freetext) = @_;

    $self->approved (\"NOW()");
    $self->change_freetext ($freetext);
    $self->update;

    my $cloak = $self->cloak;
    my $contact_id = $self->contact_id;

    my $controlsession = $c->model('Atheme')->session;
    my $contact_rs = $c->model('DB::Contact');

    my $contact = $contact_rs->find({ 'id' => $contact_id });
    my $accountname = $contact->account->accountname;

    try {
        $controlsession->command('NickServ', 'VHOST', $accountname, 'ON', $cloak);
    }
    catch (RPC::Atheme::Error $e) {
        die $e;
    }

}

=head2 rejected

Marks the cloak change as rejected.

=cut

sub reject {
    my ($self) = @_;

    $self->rejected(\"NOW()");
    $self->update;
}

1;
