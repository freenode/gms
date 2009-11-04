package GMS::Web::Controller::Group;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;
use GMS::Exception;

sub base :Chained('/') :PathPart('group') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->user->account || ! $c->user->account->contact) {
        $c->flash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use this form to enter it before registering a new group.";
        $c->session->{redirect_to} = $c->request->uri;
        $c->response->redirect($c->uri_for('/userinfo'));
    }
}

sub index :Chained('base') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{groups} = [];
    $c->stash->{pendinggroups} = [];
    foreach my $group ($c->user->account->contact->groups)
    {
        my $list;
        if ($group->status eq 'approved') {
            $list = $c->stash->{groups};
        } else {
            $list = $c->stash->{pendinggroups};
        }
        push @$list, { groupname => $group->groupname };
    }

    $c->stash->{template} = 'group/list.tt';
}


sub new_form :Chained('base') :PathPart('new') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'group/new.tt';
}

sub do_new :Chained('base') :PathPart('new/submit') :Args(0) {
    my ($self, $c) = @_;

    my $account = $c->user->account;

    my $p = $c->request->params;
    my @errors;

    my $group_rs = $c->model('DB::Group');

    if ($group_rs->find({ groupname => $p->{group_name} }))
    {
        $c->flash->{errors} = [ "A group with that name already exists." ];
        # Merge params into the flash so that they get back into the form for the second try.
        %{$c->flash} = ( %{$c->flash}, %$p );
        $c->response->redirect($c->uri_for('/group/new'));
        return;
    }

    my $group;

    try {
        $c->model('DB')->schema->txn_do(sub {
            my $address;

            if ($p->{has_address} eq 'y')
            {
                $address = $c->model('DB::Address')->create({
                        address_one => $p->{address_one},
                        address_two => $p->{address_two},
                        city => $p->{city},
                        state => $p->{state},
                        code => $p->{postcode},
                        country => $p->{country},
                        phone => $p->{phone},
                        phone2 => $p->{phone2}
                    });
            }

            $group = $group_rs->create({
                    groupname => $p->{group_name},
                    grouptype => $p->{group_type},
                    url => $p->{group_url},
                    submitted => time,
                    address => $address,
                });

            my @channels = split /, */, $p->{channel_namespace};
            foreach my $channel_ns ( @channels )
            {
                $group->add_to_channel_namespaces({ namespace => $channel_ns});
            }

            $group->add_to_group_contacts({ contact_id => $account->contact->id, primary => 1 });

            $c->stash->{contact} = $account->contact;
            $c->stash->{group} = $group;

            $c->stash->{email} = {
                to => $account->contact->email,
                bcc => $c->config->{email}->{admin_address},
                from => $c->config->{email}->{from_address},
                subject => "Group Registration for " . $group->groupname,
                template => 'new_group.tt',
            };

            $c->forward($c->view('Email'));
            if (scalar @{$c->error}) {
                my $message = $c->error->[0];
                $c->error(0);
                die GMS::Exception->new("Email sending failed. Please try again later.");
            }

            $group->update;
        });
    }
    catch (GMS::Exception::InvalidGroup $e) {
        $c->stash->{errors} = $e->message;
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->detach('new_form');
    }
    catch (GMS::Exception::InvalidAddress $e) {
        $c->stash->{errors} = [
            "If the group has its own address, then a valid address must be specified.",
            @{$e->message}
        ];
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->detach('new_form');
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = $e;
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->detach('new_form');
    }

    $c->stash->{template} = 'group/added.tt';
}

1;
