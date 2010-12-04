package GMS::Web::Controller::Userinfo;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;

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

=head2 update

Submit handler to define a user's contact information.

=cut

sub update :Path('update') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my @errors;

    my $account = $c->user->account;
    my $contact = $account->contact;

    if ($contact) {
        $c->stash->{errors} = [ "You have already defined your contact information." ];
        $c->detach('index');
    }

    try {
        $c->model('DB')->schema->txn_do(sub {
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
        });
    }
    catch (GMS::Exception::InvalidAddress $e) {
        $c->stash->{errors} = $e->message;
        %{$c->stash} = ( %{$c->stash}, %$params );
        $c->detach('index');
    }


    $c->flash->{status_msg} = "Your contact information has been updated.";

    $c->response->redirect($c->session->{redirect_to} || $c->uri_for('/userinfo'));
    delete $c->session->{redirect_to};

    return 1;
}

1;
