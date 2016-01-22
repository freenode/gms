package GMS::Web::Controller::JSON::Group;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;
use GMS::Exception;
use RPC::Atheme::Error;

=head1 NAME

GMS::Web::Controller::JSON::Group - Controller for GMS::Web

=head1 Description

JSON functions for groups.

=head1 METHODS

=head2 base

Base method for all of the handler chains in this controller. Verifies that the
user is logged in, and they have contact information defined.

=cut

sub base :Chained('/') :PathPart('json/group') :CaptureArgs(0) :Local :VerifyToken {
    my ($self, $c) = @_;

    if (! $c->user->account || ! $c->user->account->contact) {
        $c->stash->{json_success} = 0;
        $c->stash->{json_error} = "You are not logged in or have no contact info.";
        $c->response->status(403);
        $c->detach;
    }
}

=head2 single_group

Chained handler which selects a single group of which the current user is a
contact. Groups for which the user is not a contact are treated as non-existent.

=cut

sub single_group :Chained('base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $group_id) = @_;

    my $group_row = $c->user->account->contact->groups->find({ id => $group_id });
    my $gc = $c->user->account->contact->group_contacts->find ({ 'group_id' => $group_id });
    $c->stash->{gc} = $gc;

    if ( $group_row && $gc->can_access ($group_row, $c->request->path) ) {
        $c->stash->{group_row} = $group_row;

        try {
            my $session = $c->model('Atheme')->session;
            my $group = GMS::Domain::Group->new ( $session, $group_row );
            $c->stash->{group} = $group;
        }
        catch (RPC::Atheme::Error $e) {
            $c->stash->{json_success} = 0;
            $c->stash->{json_error} = "Could not talk to Atheme: " . $e->description;
            $c->detach;
        }
    } else {
        $c->stash->{json_success} = 0;
        $c->stash->{json_error} = "That group doesn't exist or you can't access it.";
        $c->response->status(404);
        $c->detach;
    }
}

=head2 listchans

Produces a list of channels in the group's namespaces.

=cut

sub listchans :Chained('single_group') :PathPart('listchans') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};

    try {
        my $client = GMS::Atheme::Client->new($c->model('Atheme')->session);

        my $result = $client->list_group_chans($group->active_channel_namespaces->all);

        $c->stash->{json_success} = 1;
        $c->stash->{json_channels} = $result;
    } catch (RPC::Atheme::Error $e) {
        $c->stash->{json_error} = $e->description;
        $c->stash->{json_success} = 0;
    }
}

1;
