package GMS::Web::Controller::JSON::Admin::Admin;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;
use GMS::Exception;
use RPC::Atheme::Error;

=head1 NAME

GMS::Web::Controller::JSON::Admin::Admin - Controller for GMS::Web

=head1 DESCRIPTION

This controller contains handlers for the admin pages.

=head1 METHODS

=head2 approve_groups

Presents the group approval form.

=cut

sub approve_groups :Chained('/json/admin/admin_only') :PathPart('approve_groups') :Args(0) {
    my ($self, $c) = @_;

    my @approve_rows = $c->model('DB::Group')->search_pending;
    my @to_approve;

    try {
        my $session = $c->model('Atheme')->session;
        foreach my $row (@approve_rows) {
            my $group = GMS::Domain::Group->new ( $session, $row );
            push @to_approve, $group;
        }
    } catch (RPC::Atheme::Error $e) {
        $c->stash->{json_error} = $e->description;
        @to_approve = @approve_rows;
    } catch (GMS::Exception $e) {
        $c->stash->{json_error} = $e->message;
        @to_approve = @approve_rows;
    }

    $c->stash->{json_to_approve} = \@to_approve;
}

=head2 do_approve_groups

Handler for the group approval form. Verifies, approves, or rejects those groups
selected for it.

=cut

sub do_approve_groups :Chained('/json/admin/admin_only') :PathPart('approve_groups/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $group_rs = $c->model('DB::Group');
    my $account = $c->user->account;

    my @approve_groups = split / /, $params->{approve_groups};
    my @verify_groups;

    if ( $params->{verify_groups} ) {
        @verify_groups = split / /, $params->{verify_groups};
    }

    my ( @approved_groups, @verified_groups, @rejected_groups );
    my ( @approved_groups_names, @verified_groups_names, @rejected_groups_names );

    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $group_id (@approve_groups, @verify_groups) {
                my $group = $group_rs->find({ id => $group_id });
                my $action = $params->{"action_$group_id"} || 'hold';
                my $freetext = $params->{"freetext_$group_id"};

                if ($action eq 'approve') {
                    $c->log->info("Approving group id $group_id (" .
                        $group->group_name . ") by " . $c->user->username . "\n");

                    notice_staff_chan($c, "[ADMIN]: " . $c->user->account->accountname . " approved group: " . $group->group_name);

                    memo_gcs (
                        $c,
                        $group,
                        $group->last_change->changed_by,
                        "Your request " .
                        "for the group registration of " .
                        $group->group_name . " has been approved."
                    );

                    $group->approve($account, $freetext);
                    push @approved_groups, $group_id;
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting group id $group_id (" .
                        $group->group_name . ") by " . $c->user->username . "\n");

                    notice_staff_chan($c, "[ADMIN]: " . $c->user->account->accountname . " rejected group: " . $group->group_name);

                    memo_gcs (
                        $c,
                        $group,
                        $group->last_change->changed_by,
                        "Your request for the group registration of " .
                        $group->group_name . " has been rejected."
                    );

                    $group->reject($account, $freetext);
                    push @rejected_groups, $group_id;
                } elsif ($action eq 'verify') {
                    $c->log->info("Verifying group id $group_id (" .
                        $group->group_name . ") by " . $c->user->username . "\n");

                    $group->verify($account, $freetext);
                    push @verified_groups, $group_id;

                    notice_staff_chan($c, "[ADMIN]: " . $c->user->account->accountname . " verified group: " . $group->group_name);
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for group id
                        $group_id in Admin::do_approve_groups");
                }
            }
        });

        $c->stash->{json_success} = 1;
        $c->stash->{json_approved} = \@approved_groups;
        $c->stash->{json_verified} = \@verified_groups;
        $c->stash->{json_rejected} = \@rejected_groups;
    }
    catch (GMS::Exception $e) {
        $c->stash->{json_error} = $e->message;
        $c->stash->{json_success} = 0;
    }
}

=head2 approve_new_gc

Presents the form to approve new contact additions.

=cut

sub approve_new_gc :Chained('/json/admin/admin_only') :PathPart('approve_new_gc') :Args(0) {
    my ($self, $c) = @_;

    my @approve_rows = $c->model('DB::GroupContact')->search_pending;
    my @to_approve;

    try {
        my $session = $c->model('Atheme')->session;

        foreach my $row ( @approve_rows ) {
            my $gc = GMS::Domain::GroupContact->new (
                $session,
                $row
            );

            push @to_approve, $gc;
        }
    }
    catch (RPC::Atheme::Error $e) {
        @to_approve = @approve_rows;
        $c->stash->{json_error} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
    }
    catch (GMS::Exception $e) {
        @to_approve = @approve_rows;
        $c->stash->{json_error} = "The following error occurred when attempting to communicate with atheme: " . $e->message . ". Data displayed below may not be current.";
    }

    $c->stash->{json_to_approve} = \@to_approve;
}

=head2 do_approve_new_gc

Handler for the group contact approval form. Verifies, approves, or rejects those group
contacts selected for it.

=cut

sub do_approve_new_gc :Chained('/json/admin/admin_only') :PathPart('approve_new_gc/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $rs = $c->model('DB::GroupContact');
    my $account = $c->user->account;

    my @approve_contacts = split / /, $params->{approve_contacts};
    my (@approved_contacts, @rejected_contacts);

    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $contact_id (@approve_contacts) {
                my $gc = $rs->find_by_id($contact_id);
                my $action = $params->{"action_$contact_id"} || 'hold';
                my $freetext = $params->{"freetext_$contact_id"};
                my $group = $gc->group;

                if ($action eq 'approve') {
                    $c->log->info("Approving group contact id $contact_id for group " . $gc->group->id . " (" .
                        $gc->contact->account->accountname . " is now group contact for " .
                        $gc->group->group_name . ") by " . $c->user->username . "\n");

                    notice_staff_chan($c,
                        "[ADMIN]: " .  $c->user->account->accountname .
                        " approved gc :" .  $gc->contact->account->accountname .
                        " for " .  $gc->group->group_name
                    );

                    memo_gcs (
                        $c,
                        $group,
                        $gc->last_change,
                        "Your request for the addition of " .
                        $gc->contact->account->accountname . " as a group " .
                        "contact of " . $group->group_name . " has been approved."
                    );

                    $gc->approve($account, $freetext);
                    push @approved_contacts, $contact_id;
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting group contact id $contact_id for group " . $gc->group->id . " (" .
                        $gc->contact->account->accountname . " rejected as group contact for " .
                        $gc->group->group_name . ") by " . $c->user->username . "\n");

                    notice_staff_chan(
                        $c,
                        "[ADMIN]: " . $c->user->account->accountname .
                        " rejected gc :" . $gc->contact->account->accountname . "
                        for " . $gc->group->group_name
                    );

                    memo_gcs (
                        $c,
                        $group,
                        $gc->last_change,
                        "Your request for the addition of " .
                        $gc->contact->account->accountname . " as a group " .
                        "contact of " . $group->group_name . " has been rejected."
                    );

                    $gc->reject($account, $freetext);
                    push @rejected_contacts, $contact_id;
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for gc id
                        $contact_id (group $gc->group->id) in Admin::do_approve_new_gc");
                }
            }
        });

        $c->stash->{json_approved} = \@approved_contacts;
        $c->stash->{json_rejected} = \@rejected_contacts;
        $c->stash->{json_success} = 1;

    }
    catch (GMS::Exception $e) {
        $c->stash->{json_error} = $e->message;
        $c->stash->{json_success} = 0;
    }
}

=head2 approve_change

Presents changes pending approval.

=cut

sub approve_change :Chained('/json/admin/admin_only') :PathPart('approve_change') :Args(0) {
    my ($self, $c) = @_;

    my $change_item = $c->request->params->{change_item};
    $c->stash->{change_item} = $change_item;

    my @approve_changes;
    my @to_approve;

    try {
        my $session = $c->model('Atheme')->session;

        if ($change_item && $change_item eq 'gcc') { #group contact change
            @approve_changes = $c->model ("DB::GroupContactChange")->active_requests();

            foreach my $change_row (@approve_changes) {
                my $change = GMS::Domain::GroupContactChange->new ($session, $change_row);
                push @to_approve, $change;
            }
        } elsif ($change_item && $change_item eq 'gc') { #group change
            @approve_changes = $c->model ("DB::GroupChange")->active_requests();

            foreach my $change_row (@approve_changes) {
                my $change = GMS::Domain::GroupChange->new ($session, $change_row);
                push @to_approve, $change;
            }
        } elsif ($change_item && $change_item eq 'cnc') { #channel namespace change
            @approve_changes = $c->model ("DB::ChannelNamespaceChange")->active_requests();

            foreach my $change_row (@approve_changes) {
                my $change = GMS::Domain::ChannelNamespaceChange->new ($session, $change_row);
                push @to_approve, $change;
            }
        } elsif ($change_item && $change_item eq 'clnc') { #cloak namespace change
            @approve_changes = $c->model ("DB::CloakNamespaceChange")->active_requests();

            foreach my $change_row (@approve_changes) {
                my $change = GMS::Domain::CloakNamespaceChange->new ($session, $change_row);
                push @to_approve, $change;
            }
        }
    }
    catch (RPC::Atheme::Error $e) {
        $c->stash->{json_error} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
        if ($change_item && $change_item eq 'gcc') { #group contact change
            @to_approve = $c->model ("DB::GroupContactChange")->active_requests();
        } elsif ($change_item && $change_item eq 'gc') { #group change
            @to_approve = $c->model ("DB::GroupChange")->active_requests();
        } elsif ($change_item && $change_item eq 'cnc' ) { #channel namespace change
            @to_approve = $c->model ("DB::ChannelNamespaceChange")->active_requests();
        } elsif ($change_item && $change_item eq 'clnc' ) { #cloak namespace change
            @to_approve = $c->model ("DB::CloakNamespaceChange")->active_requests();
        }
    }

    $c->stash->{json_pending_groupcontact} = $c->model("DB::GroupContactChange")->active_requests->count;
    $c->stash->{json_pending_group} = $c->model("DB::GroupChange")->active_requests->count;
    $c->stash->{json_pending_cns} = $c->model("DB::ChannelNamespaceChange")->active_requests->count;
    $c->stash->{json_pending_clns} = $c->model("DB::CloakNameSpaceChange")->active_requests->count;

    $c->stash->{json_to_approve} = \@to_approve;
}

=head2 do_approve_change

Processes the change approval form.
Accepted changes become the object's
current active change.

=cut

sub do_approve_change :Chained('/json/admin/admin_only') :PathPart('approve_change/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $change_item = $params->{change_item};
    my $change_rs;
    my $type;

    if ($change_item eq 'gcc') { #group contact change
        $change_rs = $c->model('DB::GroupContactChange');
        $type = "group contact change";
    } elsif ($change_item eq 'gc') { #group change
        $change_rs = $c->model('DB::GroupChange');
        $type = "group information change";
    } elsif ($change_item eq 'cnc') { #channel namespace change
        $change_rs = $c->model('DB::ChannelNamespaceChange');
        $type = "channel namespace change";
    } elsif ($change_item eq 'clnc') { #cloak namespace change
        $change_rs = $c->model('DB::CloakNamespaceChange');
        $type = "cloak namespace change";
    }

    my $account = $c->user->account;

    my @approve_changes = split / /, $params->{approve_changes};
    my (@approved_changes, @rejected_changes);

    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $change_id (@approve_changes) {
                my $change = $change_rs->find({ id => $change_id });
                my $action = $params->{"action_$change_id"} || 'hold';
                my $freetext = $params->{"freetext_$change_id"};
                my $target;
                my $group;

                if ($change_item eq 'gcc') { #group contact change
                    $target = $change->group_contact->contact->account->accountname . " ( for " . $change->group_contact->group->group_name . " ) ";
                    $group = $change->group_contact->group;
                } elsif ($change_item eq 'gc') { #group change
                    $target = $change->group->group_name;
                    $group = $change->group;
                } elsif ($change_item eq 'cnc') { #channel namespace change
                    $target = $change->namespace->namespace . " ( for " . $change->group->group_name . " ) ";
                    $group = $change->group;
                } elsif ($change_item eq 'clnc') { #cloak namespace change
                    $target = $change->namespace->namespace . " ( for " . $change->group->group_name . " ) ";
                    $group = $change->group;
                }

                if ($action eq 'approve') {
                    $c->log->info("Approving $type id $change_id" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan($c, "[ADMIN]: " . $c->user->account->accountname . " approved $type $target");

                    memo_gcs (
                        $c,
                        $group,
                        $change->changed_by,
                        "Your request for a $type for " .
                        $group->group_name . " has been approved."
                    );

                    $change->approve ($account, $freetext);
                    push @approved_changes, $change_id;
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting $type id $change_id" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan($c, "[ADMIN]: " . $c->user->account->accountname . " rejected $type $target");

                    memo_gcs (
                        $c,
                        $group,
                        $change->changed_by,
                        "Your request for a $type for " .
                        $group->group_name . " has been rejected."
                    );

                    push @rejected_changes, $change_id;
                    $change->reject ($account, $freetext);
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for $type id
                        $change_id in Admin::do_approve_change");
                }
            }
        });

        $c->stash->{json_success} = 1;
        $c->stash->{json_approved} = \@approved_changes;
        $c->stash->{json_rejected} = \@rejected_changes;
    }
    catch (GMS::Exception $e) {
        $c->stash->{json_error} = $e->message;
        $c->stash->{json_success} = 0;
    }
}

=head2 approve_cloak

Presents the form to approve cloak changes.

=cut

sub approve_cloak :Chained('/json/admin/approver_only') :PathPart('approve_cloak') :Args(0) {
    my ($self, $c) = @_;

    my $change_rs = $c->model('DB::CloakChange');
    my $schema = $c->model('DB')->schema;

    my @approve_rows = $change_rs->search_pending;
    my @to_approve;

    try {
        my $session = $c->model('Atheme')->session;
        foreach my $row (@approve_rows) {
            my $change = GMS::Domain::CloakChange->new ($session, $row);
            push @to_approve, $change;
        }
    }
    catch (RPC::Atheme::Error $e) {
        @to_approve = @approve_rows;
        $c->stash->{json_error} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
    }
    catch (GMS::Exception $e) {
        @to_approve = @approve_rows;
        $c->stash->{json_error} = "The following error occurred when attempting to communicate with atheme: " . $e->message . ". Data displayed below may not be current.";
    }

    $c->stash->{json_to_approve} = \@to_approve;
}

=head2 do_approve_cloak

Processes the form to approve cloak changes and grants the cloaks to the users.

=cut

sub do_approve_cloak :Chained('/json/admin/approver_only') :PathPart('approve_cloak/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $account = $c->user->account;

    my $change_rs = $c->model('DB::CloakChange');
    my @approve_changes = split / /, $params->{approve_changes};

    my (@approved_changes, @applied_changes, @rejected_changes);
    my $error = undef;

    try {
        my $session = $c->model('Atheme')->session;

        $c->model('DB')->schema->txn_do(sub {
            foreach my $change_id (@approve_changes) {
                my $change = $change_rs->find({ id => $change_id });
                my $action = $params->{"action_$change_id"} || 'hold';
                my $freetext = $params->{"freetext_$change_id"};
                my $group = $change->namespace->group;

                if ($action eq 'approve') {
                    $c->log->info("Approving CloakChange id $change_id" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan (
                        $c,
                        "[ADMIN]: " .  $c->user->account->accountname .
                        " approved group cloak " .  $change->cloak . " for " .
                        $change->target->accountname
                    );

                    memo_gcs (
                        $c,
                        $group,
                        $change->requestor,
                        "Your request for the " . $change->cloak . " cloak " .
                        "for " .  $change->target->accountname . " has been approved."
                    );

                    $error = $change->approve ($session, $c->user->account, $freetext);
                    push @approved_changes, $change_id;
                } elsif ($action eq 'apply') {
                    $c->log->info ("Marking cloakChange id $change_id as applied" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan (
                        $c,
                        "[ADMIN]: " .  $c->user->account->accountname .
                        " marked as applied: group cloak " .  $change->cloak . "
                        for " .  $change->target->accountname
                    );

                   memo_gcs (
                        $c,
                        $group,
                        $change->requestor,
                        "Your request for the " . $change->cloak . " cloak " .
                        "for " .  $change->target->accountname . " has been applied."
                    );

                    $change->apply ($c->user->account, $freetext);
                    push @applied_changes, $change_id;
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting CloakChange id $change_id" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan (
                        $c,
                        "[ADMIN]: " .  $c->user->account->accountname .
                        " rejected cloak " .  $change->cloak . " for " .
                        $change->target->accountname
                    );

                    memo_gcs (
                        $c,
                        $group,
                        $change->requestor,
                        "Your request for the " . $change->cloak . " cloak " .
                        "for " .  $change->target->accountname . " has been rejected."
                    );

                    $change->reject ($c->user->account, $freetext);
                    push @rejected_changes, $change_id;
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for CloakChange id
                        $change_id in Admin::do_approve_cloak");
                }
            }
        });

        if (!$error) {
            $c->stash->{json_success} = 1;
            $c->stash->{json_approved} = \@approved_changes;
            $c->stash->{json_rejected} = \@rejected_changes;
            $c->stash->{json_applied} = \@applied_changes;
        } else {
            $c->stash->{json_error} = $error->description;
            $c->stash->{json_failed} = \@approved_changes;
            $c->stash->{json_applied} = \@applied_changes;
            $c->stash->{json_rejected} = \@rejected_changes;
        }
    }
    catch (GMS::Exception $e) {
        $c->stash->{json_error} = $e->message;
        $c->stash->{json_success} = 0;
    }
    catch (RPC::Atheme::Error $e) {
        $c->stash->{json_error} = $e->description;
        $c->stash->{json_failed} = \@approve_changes;
        $c->stash->{json_success} = 0;
    }
}

=head2 approve_channel_requests

Presents the form to approve channel requests.

=cut

sub approve_channel_requests :Chained('/json/admin/approver_only') :PathPart('approve_channel_requests') :Args(0) {
    my ($self, $c) = @_;

    my $req_rs = $c->model('DB::ChannelRequest');

    my @approve_requests = $req_rs->search_pending;
    my @to_approve;

    try {
        my $session = $c->model('Atheme')->session;

        foreach my $row (@approve_requests) {
            my $req = GMS::Domain::ChannelRequest->new ( $session, $row );
            push @to_approve, $req;
        }
    }
    catch (RPC::Atheme::Error $e) {
        @to_approve = @approve_requests;
        $c->stash->{json_error} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
    }

    $c->stash->{json_to_approve} = \@to_approve;
}

=head2 do_approve_channel_requests

Processes the form to approve channel requests
and attempts to carry out the changes in Atheme.

=cut

sub do_approve_channel_requests :Chained('/json/admin/approver_only') :PathPart('approve_channel_requests/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $account = $c->user->account;

    my $req_rs = $c->model('DB::ChannelRequest');
    my @approve_requests = split / /, $params->{approve_requests};

    my ( @approved_requests, @rejected_requests, @applied_requests );
    my $error = undef;

    try {
        my $session = $c->model('Atheme')->session;

        $c->model('DB')->schema->txn_do(sub {
            foreach my $req_id (@approve_requests) {
                my $request = $req_rs->find({ id => $req_id });
                my $action = $params->{"action_$req_id"} || 'hold';
                my $freetext = $params->{"freetext_$req_id"};
                my $group = $request->namespace->group;

                my $req_txt = "";

                if ($request->request_type eq 'transfer') {
                    $req_txt = " to " . $request->target->accountname;
                }

                if ($action eq 'approve') {
                    $c->log->info("Approving ChannelRequest id $req_id" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan (
                        $c,
                        "[ADMIN]: " .  $c->user->account->accountname .
                        " approved " .  $request->request_type . " of " .
                        $request->channel . $req_txt
                    );

                    memo_gcs (
                        $c,
                        $group,
                        $request->requestor->account,
                        "Your request for the " .
                        $request->request_type . " of " . $request->channel .
                        $req_txt . " has been approved."
                    );

                    $error = $request->approve ($session, $account, $freetext);
                    push @approved_requests, $req_id;
                } elsif ($action eq 'apply') {
                    $c->log->info ("Marking ChannelRequest id $req_id as applied" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan (
                        $c,
                        "[ADMIN]: " .  $c->user->account->accountname .
                        " marked " .  $request->request_type . " of " .
                        $request->channel . $req_txt . " as applied"
                    );


                    memo_gcs (
                        $c,
                        $group,
                        $request->requestor->account,
                        "Your request for the " .
                        $request->request_type . " of " . $request->channel .
                        $req_txt . " has been applied."
                    );

                    $request->apply ($c->user->account, $freetext);
                    push @applied_requests, $req_id;
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting ChannelRequest id $req_id" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan (
                        $c,
                        "[ADMIN]: " .  $c->user->account->accountname .
                        " rejected " .  $request->request_type . " of " .
                        $request->channel . $req_txt
                    );

                    memo_gcs (
                        $c,
                        $group,
                        $request->requestor->account,
                        "Your request for the " .
                        $request->request_type . " of " . $request->channel .
                        $req_txt . " has been rejected"
                    );

                    $request->reject ($c->user->account, $freetext);
                    push @rejected_requests, $req_id;
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for ChannelRequest id
                        $req_id in Admin::do_approve_channel_requests");
                }
            }
        });

        if (!$error) {
            $c->stash->{json_success} = 1;
            $c->stash->{json_approved} = \@approved_requests;
            $c->stash->{json_rejected} = \@rejected_requests;
            $c->stash->{json_applied} = \@applied_requests;
        } else {
            $c->stash->{json_error} = $error->description;
            $c->stash->{json_failed} = \@approved_requests;
            $c->stash->{json_applied} = \@applied_requests;
            $c->stash->{json_rejected} = \@rejected_requests;
        }
    }
    catch (GMS::Exception $e) {
        $c->stash->{json_error} = $e->message;
        $c->stash->{json_success} = 0;
    }
    catch (RPC::Atheme::Error $e) {
        $c->stash->{json_error} = $e->description;
        $c->stash->{json_failed} = \@approve_requests;
        $c->stash->{json_success} = 0;
    }
}


=head2 approve_namespaces

Presents the form to accept channel and cloak namespaces.

=cut

sub approve_namespaces :Chained('/json/admin/admin_only') :PathPart('approve_namespaces') :Args(0) {
    my ($self, $c) = @_;

    my @to_approve;

    my $approve_item = $c->request->params->{approve_item};
    $c->stash->{approve_item} = $approve_item;

    if ($approve_item && $approve_item eq 'cns') { #channel namespaces
        @to_approve = $c->model ("DB::ChannelNamespace")->search_pending();
    } elsif ($approve_item && $approve_item eq 'clns') { #cloak namespces
        @to_approve = $c->model ("DB::CloakNamespace")->search_pending();
    }

    $c->stash->{json_to_approve} = \@to_approve;

    $c->stash->{json_pending_channel} = $c->model ("DB::ChannelNamespace")->search_pending->count;
    $c->stash->{json_pending_cloak} = $c->model ("DB::CloakNamespace")->search_pending->count;
}

=head2 do_approve_namespaces

Processes the form to approve namespaces.

=cut

sub do_approve_namespaces :Chained('/json/admin/admin_only') :PathPart('approve_namespaces/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $namespace_rs;
    my $type;

    my $approve_item = $c->request->params->{approve_item};

    if ($approve_item eq 'cns') { #channel namespaces
        $namespace_rs = $c->model ("DB::ChannelNamespace");
        $type = "channel namespace";
    } elsif ($approve_item eq 'clns') { #cloak namespces
        $namespace_rs = $c->model ("DB::CloakNamespace");
        $type = "cloak namespace";
    }

    my $account = $c->user->account;

    my @approve_namespaces = split / /, $params->{approve_namespaces};
    my (@approved_namespaces, @rejected_namespaces);

    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $namespace_id (@approve_namespaces) {
                my $namespace = $namespace_rs->find({ id => $namespace_id });
                my $action = $params->{"action_$namespace_id"} || 'hold';
                my $freetext = $params->{"freetext_$namespace_id"};
                my $group = $namespace->group;

                if ($action eq 'approve') {
                    $c->log->info("Approving $type id $namespace_id" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan (
                        $c,
                        "[ADMIN]: " .  $c->user->account->accountname .
                        " approved $type " . $namespace->namespace . " for " .
                        $namespace->group->group_name
                    );

                    memo_gcs (
                        $c,
                        $group,
                        $namespace->last_change->changed_by,
                        "Your request for the $type " .
                        $namespace->namespace . " for " .
                        $namespace->group->group_name . " has been approved."
                    );

                    $namespace->approve ($account, $freetext);
                    push @approved_namespaces, $namespace_id;
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting $type id $namespace_id" .
                        " by " . $c->user->username . "\n");

                    notice_staff_chan (
                        $c,
                        "[ADMIN]: " .  $c->user->account->accountname .
                        " rejected $type " . $namespace->namespace . " for " .
                        $namespace->group->group_name
                    );

                    memo_gcs (
                        $c,
                        $group,
                        $namespace->last_change->changed_by,
                        "Your request for the $type " .
                        $namespace->namespace . " for " .
                        $namespace->group->group_name . " has been rejected."
                    );

                    $namespace->reject ($account, $freetext);
                    push @rejected_namespaces, $namespace_id;
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for channel namespace id
                        $namespace_id in Admin::do_approve_channel_namespaces");
                }
            }
        });

        $c->stash->{json_success} = 1;
        $c->stash->{json_approved} = \@approved_namespaces;
        $c->stash->{json_rejected} = \@rejected_namespaces;
    }
    catch (GMS::Exception $e) {
        $c->stash->{json_error} = $e->message;
        $c->stash->{json_success} = 0;
    }
}

=head2 notice_staff_chan

Sends a notice to the staff channel about an action, dying quietly if there's
an error.

=cut

sub notice_staff_chan {
    my ($c, @notices) = @_;

    # Don't die if this fails
    eval {
        my $client = GMS::Atheme::Client->new ( $c->model('Atheme')->session );

        $client->notice_staff_chan(@notices);
    };
}

=head2 memo_gcs

Sends a memo to a group's primary GC's, as well as the requestor.

=cut

sub memo_gcs {
    my ($c, $group, $requestor_account, $memo) = @_;

    return if $group->status->is_deleted;

    my @gcs = $group->primary_group_contacts->count > 0 ? $group->primary_group_contacts->all : $group->group_contacts->all;

    eval {
        my $client = GMS::Atheme::Client->new ( $c->model('Atheme')->session );

        my $requestor_notified = 0;

        # Always notify primary gcs.
        foreach my $gc (@gcs) {
            $client->memo($gc->contact->account->accountname, $memo);

            if ($gc->contact->account->id eq $requestor_account->id) {
                $requestor_notified = 1;
            }
        }

        # If the requestor is a secondary gc and hasn't yet been memoed, memo them now.
        if (!$requestor_notified) {
            $client->memo($requestor_account->accountname, $memo);
        }
    };
}

1;
