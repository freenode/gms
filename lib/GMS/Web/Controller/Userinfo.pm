package GMS::Web::Controller::Userinfo;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;

use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

=head1 NAME

GMS::Web::Controller::Userinfo - Controller for GMS::Web

=head1 DESCRIPTION

Contains the handlers to display, define and update a user's contact
information.

=head1 METHODS

=head2 index

Displays the user's contact information if it has been defined, or the form to
define it if it has not.

=cut

sub index :Path :Args(0) {
    my ($self, $c ) = @_;

    my $account = $c->user->account;

    if (! $account->contact) {
        $c->stash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use the form below to define it.";

        $c->stash->{template} = 'contact/update_userinfo.tt';
    } else {
        my $contact = $account->contact;

        $c->stash->{user_name} = $contact->name;
        $c->stash->{user_email} = $contact->email;

        my $address = $contact->address;

        if (! $address) {
            $c->stash->{status_msg} = "You don't currently have an address defined.\n" .
                                      "Use the form below to define it.";
        } else {
            $c->stash->{address_one} = $address->address_one;
            $c->stash->{address_two} = $address->address_two;
            $c->stash->{city} = $address->city;
            $c->stash->{state} = $address->state;
            $c->stash->{postcode} = $address->code;
            $c->stash->{country} = $address->country;
            $c->stash->{phone_one} = $address->phone;
            $c->stash->{phone_two} = $address->phone2;
        }

        $c->stash->{template} = 'contact/view_userinfo.tt';
    }
}

=head2 edit

Displays the form to edit the user's contact information.
If the form hasn't been submitted already,
it is populated with the contact's current data.

=cut

sub edit :Path('edit') :Args(0) {
    my ($self, $c) = @_;

    my $contact = $c->user->account->contact;

    my $active_change = $contact->active_change;
    my $last_change = $contact->last_change;
    my $change;

    if ($last_change->change_type->is_request) {
        $change = $last_change;
        $c->stash->{status_msg} = "Warning: There is already a change request pending for your contact information.
         As a result, information from the current request is used instead of the active change.";
    } else {
        $change = $active_change;
    }

    my $address = $change->address;

    if (!$c->stash->{form_submitted}) {
        $c->stash->{user_name} = $change->name;
        $c->stash->{user_email} = $change->email;

        $c->stash->{address_one} = $address->address_one;
        $c->stash->{address_two} = $address->address_two;
        $c->stash->{city} = $address->city;
        $c->stash->{state} = $address->state;
        $c->stash->{postcode} = $address->code;
        $c->stash->{country} = $address->country;
        $c->stash->{phone_one} = $address->phone;
        $c->stash->{phone_two} = $address->phone2;
    }

    $c->stash->{edit} = 1;
    $c->stash->{template} = 'contact/update_userinfo.tt';
}

=head2 update

Submit handler to define and edit a user's contact information.

=cut

sub update :Path('update') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my @errors;

    my $account = $c->user->account;
    my $contact = $account->contact;
    my ($msg, $address);

    if ($contact) {
        try {
            if ($params->{update_address} eq 'y') {
                $address = $c->model('DB::Address')->create({
                        address_one => $params->{address_one},
                        address_two => $params->{address_two},
                        city => $params->{city},
                        state => $params->{state},
                        code => $params->{postcode},
                        country => $params->{country},
                        phone => $params->{phone_one},
                        phone2 => $params->{phone_two}
                    });
            }
            $contact->change ($account->id, 'request', { 'name' => $params->{user_name}, 'email' => $params->{user_email}, address => $address });
            $msg = "Successfully submitted the change request. Please wait for staff to approve the change.";
        }
        catch (GMS::Exception::InvalidAddress $e) {
            $c->stash->{errors} = $e->message;
            %{$c->stash} = ( %{$c->stash}, %$params );
            $c->stash->{form_submitted} = 1;
            $c->detach('edit');
        }
    } else {
        try {
            my $address = $c->model('DB::Address')->create({
                address_one => $params->{address_one},
                address_two => $params->{address_two},
                city => $params->{city},
                state => $params->{state},
                code => $params->{postcode},
                country => $params->{country},
                phone => $params->{phone_one},
                phone2 => $params->{phone_two}
            });
            $contact = $c->model('DB::Contact')->create({
                account_id => $account->id,
                name => $params->{user_name},
                email => $params->{user_email},
                address => $address->id
            });
            $msg = "Your contact information has been updated.";
        }
        catch (GMS::Exception::InvalidAddress $e) {
            $c->stash->{errors} = $e->message;
            %{$c->stash} = ( %{$c->stash}, %$params );
            $c->detach('index');
        }
    }

    $c->flash->{status_msg} = $msg;

    $c->response->redirect($c->session->{redirect_to} || $c->uri_for('/userinfo'));
    delete $c->session->{redirect_to};

    return 1;
}

1;
