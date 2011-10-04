package GMS::Web::Controller::Group;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Socket;
use TryCatch;
use GMS::Exception;

use HTTP::Request;
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

sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
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

    if (! $c->user->account || ! $c->user->account->contact) {
        $c->flash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use this form to enter it before registering a new group.";
        $c->session->{redirect_to} = $c->request->uri;
        $c->response->redirect($c->uri_for('/userinfo'));
        return;
    }
    $c->stash->{groups} = [];
    $c->stash->{pendinggroups} = [];
    foreach my $group ($c->user->account->contact->groups)
    {
        my $list;
        if ($group->status->is_active) {
            $list = $c->stash->{groups};
        } elsif (! $group->status->is_deleted) {
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

sub verify :Chained('single_group') :PathPart('verify') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'group/verify.tt';
}
sub verify_web :Chained('single_group') :PathPart('verify/web') :Args(0) {
    my ($self, $c) = @_;
    my $group = $c->stash->{group};
    if ($group) {
        my $request = HTTP::Request->new(GET => $group->verify_url);
        my $ua = LWP::UserAgent->new;
        my $response = $ua->request($request);
        my $content = trim($response->content);
        if ($content eq $group->verify_token) {
            $c->stash->{msg} = "Successfully verified site ownership. Your group status is now pending-staff.<br/>Please do not remove the file containing your verification token until you are instructed to do so via e-mail.";
            $group->change ($c->user->account->contact->id, "workflow_change", { status=>'pending-staff', verify_auto=>1 } );
        }
        else { 
            $c->stash->{msg} = "The token was incorrect. Please create a file with content " . $group->verify_token . " and upload it in " . $group->verify_url . ".";
        }
    }
       $c->stash->{template} = 'group/verify_done.tt';
    
}

sub verify_dns :Chained('single_group') :PathPart('verify/dns') :Args(0) {
    my ($self, $c) = @_;
    my $group = $c->stash->{group};
    if ($group) {
        my $packed = gethostbyname($group->verify_dns); 
        if ($packed) {
            my $address = inet_ntoa($packed);
            if ($address eq "140.211.167.100") {
                $c->stash->{msg} = "Successfully verified domain ownership. Your group status is now pending-staff.";
                $group->change ($c->user->account->contact->id, "workflow_change", { status=>'pending-staff', verify_auto=>1 } );
            }
            else { 
                $c->stash->{msg} = "Please create a CNAME record for " . $group->verify_dns . " pointing to freenode.net.";
            }
        }
        else { 
            $c->stash->{msg} = "Please create a CNAME record for " . $group->verify_dns . " pointing to freenode.net.";
        }
    }
       $c->stash->{template} = 'group/verify_done.tt';
    
}
sub verify_git :Chained('single_group') :PathPart('verify/git') :Args(0) {
    my ($self, $c) = @_;
       $c->stash->{template} = 'group/verify_git.tt';
}
sub verify_git_submit :Chained('single_group') :PathPart('verify/git/submit') :Args(0) {
    my ($self, $c) = @_;
     my $giturl = $c->request->params->{giturl};
    my $group = $c->stash->{group};
    if ($giturl && $giturl =~ /^[a-zA-Z0-9:\.\/_?+-]*$/) {
        $c->stash->{msg} = 'Successfully updated the gitweb/csvweb url. Please wait for a staffer to verify your group.';
        $group->change ($c->user->account->contact->id, "workflow_change", { status=>'pending-staff', verify_auto=>0 } );
        $group->git_url ($giturl);
        $group->update;
    }
    else {
        $c->stash->{error_msg} = 'You need to provide a valid URL.';
    }
    $c->stash->{template} = 'group/verify_done.tt';
    
}
sub verify_other :Chained('single_group') :PathPart('verify/other') :Args(0) {
    my ($self, $c) = @_;
       $c->stash->{template} = 'group/verify_other.tt';
}
sub verify_other_submit :Chained('single_group') :PathPart('verify/other/submit') :Args(0) {
    my ($self, $c) = @_;
     my $reason = $c->request->params->{verify_other};
    my $group = $c->stash->{group};
    if ($reason) {
        $c->stash->{msg} = 'Thank you. Your group status is now pending-staff. Please wait for a staffer to approve or decline your group request.<br/>';
        $group->change ($c->user->account->contact->id, "workflow_change", { status=>'pending-staff', verify_auto => 0 } );
        $group->verify_freetext ($reason);
        $group->update;
    }
    else {
        $c->stash->{error_msg} = 'You need to provide a reason.';
    }
    $c->stash->{template} = 'group/verify_done.tt';
    
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

            $group->add_to_group_contacts({ contact_id => $account->contact->id, primary => 1, account => $account->contact->id });

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
