package GMS::Web::Controller::Cloak;

use strict;
use warnings;
use base qw (GMS::Web::TokenVerification);

=head1 NAME

GMS::Web::Controller::Cloak - Controller for GMS::Web

=head1 DESCRIPTION

Shows the contact's pending group cloaks and allows them to accept or decline them.

=cut

=head1 METHODS

=head2 base

Base method for all of the handler chains in this controller. Verifies that the
user is logged in, and that they have contact information defined. If not, then
redirect to the contact information form.

=cut

sub base :Chained('/') :PathPart('cloak') :CaptureArgs(0) :Local :VerifyToken {
    my ($self, $c) = @_;

    if (! $c->user->account || ! $c->user->account->contact) {
        $c->flash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use this form to enter it before registering a new group.";
        $c->session->{redirect_to} = $c->request->uri;
        $c->response->redirect($c->uri_for('/userinfo'));
    }
}

=head2 index

Displays all pending cloaks for the contact, if any.

=cut

sub index :Chained('base') :PathPart('') :Args(0) {
    my ($self, $c ) = @_;
    
    if (! $c->user->account || ! $c->user->account->contact) {
        $c->flash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use this form to enter it before registering a new group.";
        $c->session->{redirect_to} = $c->request->uri;
        $c->response->redirect($c->uri_for('/userinfo'));
        return;
    }

    my $contact = $c->user->account->contact;
    my $change_rs = $c->model("DB::CloakChange");

    my @cloaks = $change_rs->search_offered->search({ 'contact_id' => $contact->id });

    $c->stash->{cloaks} = \@cloaks;
    $c->stash->{template} = 'cloak.tt';
}

=head2 cloak

Chained handler which selects a cloak that has been granted to the user.

=cut

sub cloak :Chained('base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $cloak_id) = @_;

    my $change_rs = $c->model("DB::CloakChange");
    my $contact = $c->user->account->contact;

    my $cloak = $change_rs->find ({ id => $cloak_id });

    if (!$cloak || $cloak->contact_id != $contact->id) {
        $c->stash->{error_msg} = "That cloak doesn't exist or hasn't been assigned to you.";
        $c->detach('index');
    }

    $c->stash->{cloak} = $cloak;
}

=head2 approve

Approves or rejects the cloak change.

=cut

sub approve :Chained('cloak') :PathPart('approve') :Args(0) {
    my ($self, $c) = @_;

    my $cloak = $c->stash->{cloak};

    if ($c->request->body_params->{action} eq 'approve') {
        $cloak->accept();

        $c->stash->{status_msg} = "Successfully approved the cloak. Please wait for staff to also approve it.";
    } elsif ($c->request->body_params->{action} eq 'reject') {
        $cloak->reject();

        $c->stash->{status_msg} = "Successfully rejected the cloak.";
    }


    $c->detach ('index');
}

1;
