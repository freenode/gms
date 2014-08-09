package GMS::Domain::Group;

use strict;
use warnings;
use Moose;

use GMS::Domain::GroupContact;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_group_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id group_name add_contact submitted auto_verify verify_auto active_change change url active_channel_namespaces add_to_channel_namespaces active_cloak_namespaces add_to_cloak_namespaces cloak_namespaces channel_namespaces deleted status group_type verify_url verify_token verify_dns verify_freetext last_change invite_contact get_change_string) ]
);

=head1 PACKAGE

GMS::Domain::Group

=head1 DESCRIPTION

Represents a Group. It contains all the
database columns from the Group table,
minus any group contact information which
instead are GMS::Domain::GroupContact objects.

=cut

=head1 METHODS

=head2 new

Constructor. Takes an Atheme session object
and a database row object.

=cut

sub new {
    my ($class, $session, $row) = @_;

    my $self = { };

    $self->{_session} = $session;
    $self->{_dbic_group_row} = $row;

    my @gc_rows = $row->group_contacts;
    my @active_gc_rows = $row->active_group_contacts;
    my @editable_gc_rows = $row->editable_group_contacts;
    my @active_contact_rows = $row->active_contacts;

    my ( @gcs, @active_gcs, @editable_gcs, @active_contacts );

    try {
        foreach my $gc ( @gc_rows ) {
            my $contact = GMS::Domain::GroupContact->new ( $session, $gc );

            push @gcs, $contact;
        }
        foreach my $gc ( @active_gc_rows ) {
            my $contact = GMS::Domain::GroupContact->new ( $session, $gc );

            push @active_gcs, $contact;
        }
        foreach my $gc ( @editable_gc_rows ) {
            my $contact = GMS::Domain::GroupContact->new ( $session, $gc );

            push @editable_gcs, $contact;
        }
        foreach my $contact_row ( @active_contact_rows ) {
            my $contact = GMS::Domain::Contact->new ( $session, $contact_row );

            push @active_contacts, $contact;
        }

        $self->{_group_contacts} = \@gcs;
        $self->{_active_group_contacts} = \@active_gcs;
        $self->{_editable_group_contacts} = \@editable_gcs;
        $self->{_active_contacts} = \@active_contacts;
    }
    catch (RPC::Atheme::Error $e) {
        die $e;
    }
    catch (GMS::Exception $e) {
        die $e;
    }

    bless $self, $class;
}

=head2 group_contacts

Returns an array of GMS::Domain::GroupContact objects
representing all of the group's contacts.

=cut

sub group_contacts {
    my ($self) = @_;

    my $gcs = $self->{_group_contacts};
    return @$gcs;
}

=head2 active_group_contacts

Returns an array of GMS::Domain::GroupContact objects
representing the group's active contacts.

=cut

sub active_group_contacts {
    my ($self) = @_;

    my $gcs = $self->{_active_group_contacts};
    return @$gcs;
}

=head2 active_contacts

Returns an array of GMS::Domain::Contact objects
representing the group's active contacts.

=cut

sub active_contacts {
    my ($self) = @_;

    my $contacts = $self->{_active_contacts};
    return @$contacts;
}

=head2 editable_group_contacts

Returns an array of GMS::Domain::GroupContact objects
representing the group's editable contacts.
(Group Contacts can edit information for active and
retired contacts)

=cut

sub editable_group_contacts {
    my ($self) = @_;

    my $gcs = $self->{_editable_group_contacts};
    return @$gcs;
}

=head2 group_row

Returns the database row representing the group

=cut

sub group_row {
    my ($self) = @_;

    return $self->{_dbic_group_row};
}

=head2 TO_JSON

Returns a representative object for the JSON parser.

=cut

sub TO_JSON {
    my ($self) = @_;

    my @gcs = $self->group_contacts;
    my $first = shift @gcs;

    my $accountname = undef;
    my $dropped = undef;
    my $initial = undef;

    if ($first) {
        $accountname = $first->contact->account->accountname;
        $dropped = $first->contact->account->is_dropped;
    }

    if ($self->channel_namespaces->first) {
        $initial = $self->channel_namespaces->first->namespace;
    }

    return {
        'id'                              => $self->id,
        'name'                            => $self->group_name,
        'url'                             => $self->url,
        'type'                            => $self->group_type->value,
        'status'                          => $self->status->value,
        'initial_contact_account_name'    => $accountname,
        'initial_contact_account_dropped' => $dropped,
        'initial_namespace_name'          => $initial,
    }
}

1;
