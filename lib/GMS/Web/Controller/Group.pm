package GMS::Web::Controller::Group;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;
use GMS::Exception;

=head1 NAME

GMS::Web::Controller::Group - Controller for GMS::Web

=head1 DESCRIPTION

This controller contains the handlers for group management pages accessible to
group contacts.

=head1 METHODS

=head2 base

Base method for all of the handler chains in this controller. Verifies that the
user is logged in, and that they have contact information defined. If not, then
redirect to the contact information form.

=cut

sub base :Chained('/') :PathPart('group') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->user->account || ! $c->user->account->contact) {
        $c->flash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use this form to enter it before registering a new group.";
        $c->session->{redirect_to} = $c->request->uri;
        $c->response->redirect($c->uri_for('/userinfo'));
    }
}

=head2 index

Show a group contact a list of his active and pending groups.

=cut

sub index :Chained('base') :PathPart('') :Args(0) {
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
        push @$list, $group;
    }

    $c->stash->{template} = 'group/list.tt';
}

=head2 single_group

Chained handler which selects a single group of which the current user is a
contact. Groups for which the user is not a contact are treated as non-existent.

=cut

sub single_group :Chained('base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $group_id) = @_;

    my $group = $c->user->account->contact->groups->find({ id => $group_id });

    if ($group) {
        $c->stash->{group} = $group;
    } else {
        $c->detach('/default');
    }
}

=head2 view

Displays a group's information to one of its contacts.

=cut

sub view :Chained('single_group') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'group/view.tt';
}

=head2 new_form

Displays the form to register a new group.

=cut

sub new_form :Chained('base') :PathPart('new') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'group/new.tt';
}

=head2 do_new

Submit handler for the new group form.

Using the information submitted, creates a new Address if applicable, then a
Group, then adds the current user as the first group contact. Any channel and
cloak namespaces claimed are also added.

=cut

sub do_new :Chained('base') :PathPart('new/submit') :Args(0) {
    my ($self, $c) = @_;

    my $account = $c->user->account;

    my $p = $c->request->params;
    my @errors;

    my $group_rs = $c->model('DB::Group');

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
                    group_name => $p->{group_name},
                    group_type => $p->{group_type},
                    url => $p->{group_url},
                    address => $address,
                    account => $c->user->account,
                });

            my @channels = split /, */, $p->{channel_namespace};
            foreach my $channel_ns ( @channels )
            {
                $group->add_to_channel_namespaces({ namespace => $channel_ns});
            }

            $group->add_to_group_contacts({ contact_id => $account->contact->id, primary => 1 });

            $c->stash->{contact} = $account->contact;
            $c->stash->{group} = $group;

            $c->stash->{join_gab} = $p->{join_gab};
            $c->stash->{gab_email} = $p->{gab_email} || $account->contact->email;

            $c->stash->{email} = {
                to => $account->contact->email,
                bcc => $c->config->{email}->{admin_address},
                from => $c->config->{email}->{from_address},
                subject => "Group Registration for " . $group->group_name,
                template => 'new_group.tt',
            };

            #$c->forward($c->view('Email'));
            #if (scalar @{$c->error}) {
            #    my $message = $c->error->[0];
            #    $c->error(0);
            #    die GMS::Exception->new("Email sending failed. Please try again later.");
            #}

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
