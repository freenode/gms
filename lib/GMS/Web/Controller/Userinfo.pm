package GMS::Web::Controller::Userinfo;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Error qw/:try/;

use GMS::Util::Address;

sub index :Path :Args(0) {
    my ($self, $c ) = @_;

    my $account = $c->user->account;

    if (! $account->contact) {
        $c->stash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use the form below to define it.";
    } else {
        my $contact = $account->contact;

        $c->stash->{user_name} = $contact->name;

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
    }

    $c->stash->{template} = 'userinfo.tt';
}

sub update :Path('update') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my @errors;

    if (! GMS::Util::Address::validate_address($params, \@errors))
    {
        $c->flash->{errors} = \@errors;
        $c->response->redirect($c->uri_for('/userinfo'));
        return 0;
    }

    my $account = $c->user->account;
    my $contact = $account->contact;

    if (! $contact) {
        $contact = $c->model('DB::Contact')->create({
                account_id => $account->id
            });
    }

    my $address = $contact->address;

    if (! $address)
    {
        $address = $c->model('DB::Address')->create({});
        $contact->address_id($address->id);
        $contact->update;
    }

    my $p = $c->request->params;

    $contact->name        ($p->{user_name});

    $address->address_one ($p->{address_one});
    $address->address_two ($p->{address_two});
    $address->city        ($p->{city});
    $address->state       ($p->{state});
    $address->code        ($p->{postcode});
    $address->country     ($p->{country});
    $address->phone       ($p->{phone_one});
    $address->phone2      ($p->{phone_two});

    $contact->update;
    $address->update;

    $c->flash->{status_msg} = "Your contact information has been updated.";
    $c->response->redirect($c->uri_for('/userinfo'));
    return 1;
}

1;
