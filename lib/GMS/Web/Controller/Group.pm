package GMS::Web::Controller::Group;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Error qw/:try/;

use GMS::Util::Group;

sub base :Chained('/') :PathPart('group') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->user->account->contact) {
        $c->flash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use this form to enter it before registering a new group.";
        $c->response->redirect($c->uri_for('/userinfo'));
    }
}


sub new_form :Chained('base') :PathPart('new') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'newgroup.tt';
}

sub do_new :Path('new/submit') :Args(0) {
    my ($self, $c) = @_;

    my $account = $c->user->account;

    my $p = $c->request->params;
    my @errors;

    if (! GMS::Util::Group::validate_group($p, \@errors))
    {
        $c->flash->{errors} = \@errors;
        # Merge params into the flash so that they get back into the form for the second try.
        %{$c->flash} = ( %{$c->flash}, %$p );
        $c->response->redirect($c->uri_for('/group/new'));
        return;
    }

    my $group_rs = $c->model('DB::Group');

    if ($group_rs->find({ groupname => $p->{group_name} }))
    {
        $c->flash->{errors} = [ "A group with that name already exists." ];
        # Merge params into the flash so that they get back into the form for the second try.
        %{$c->flash} = ( %{$c->flash}, %$p );
        $c->response->redirect($c->uri_for('/group/new'));
        return;
    }

    my $group = $group_rs->create({
            groupname => $p->{group_name},
            grouptype => $p->{group_type},
            url => $p->{group_url},
            status => 'new',
        });

    if ($p->{has_address})
    {
        my $address = $c->model('DB::Address')->create({
                address_one => $p->{address_one},
                address_two => $p->{address_two},
                city => $p->{city},
                state => $p->{state},
                code => $p->{postcode},
                country => $p->{country},
                phone => $p->{phone_one},
                phone2 => $p->{phone_two}
            });
        $group->address($address);
    }

    my @channels = split /, */, $p->{channel_namespace};
    foreach my $channel_ns ( @channels )
    {
        $group->add_to_channel_namespaces({ namespace => $channel_ns});
    }

    $group->add_to_group_contacts({ contact_id => $account->contact->id });

    $group->update;

    $c->stash->{groupname} = $group->groupname;
    $c->stash->{template} = 'group_added.tt';
}

1;
