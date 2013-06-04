#!/usr/bin/perl

# Creates database entries for
# ALL the tables.

use Carp::Always;
use strict;
use warnings;

use Data::UUID;

use FindBin;
use lib "$FindBin::Bin/../lib";

use GMS::Schema;

my $schema = GMS::Schema->do_connect;

my $account_rs = $schema->resultset ('Account');
my $address_rs = $schema->resultset ('Address');
my $contact_rs = $schema->resultset ('Contact');
my $group_rs = $schema->resultset ('Group');
my $request_rs = $schema->resultset("ChannelRequest");
my $cloak_rs = $schema->resultset("CloakChange");

sub createAccountUID {
    my $ug    = new Data::UUID;
    my $uuid = $ug->create();
    my $id = $ug->to_string ($uuid);

    return substr $id, 0, 8;
}

for (my $i = 0; $i < 150; $i++) {
    print $i . "\n";

    #accounts
    my $uid = createAccountUID;

    my $adminaccount = $account_rs->search({accountname => 'admin'})->single;

    my $account = $account_rs->create(
        {
            accountname => 'account' . $i,
            id => $uid,
            dropped => 1
        });

    #addresses
    my $address = $address_rs->create(
        {
            address_one => 'Address' . $i,
            city => 'City' . $i,
            state => 'State' . $i,
            code => '00' . $i,
            phone => '0123456789',
            country => 'Country' . $i,
        });
    my $address2 = $address_rs->create(
        {
            address_one => 'Address Two' . $i,
            city => 'City Two' . $i,
            state => 'State Two' . $i,
            code => '01' . $i,
            phone => '0123456789',
            country => 'Country Two' . $i,
        });

    #contacts
    my $contact = $contact_rs->create({
        account_id => $account->id,
        name => 'Name' . $i,
        email => 'user' . $i . '@example.com',
        address => $address->id
    });

    #contact changes
    my $change;

    if ( $i%4 == 0  ) {
        $change = $contact->change (
            $account,
            'request',
            {
                name => 'Name Two' . $i
            });
    } elsif ( $i%4 == 1 ) {
        $change = $contact->change (
            $account,
            'request',
            {
                email => 'Email Two' . $i
            });
    } elsif ( $i%4 == 2 ) {
        $change = $contact->change (
            $account,
            'request',
            {
                address => $address2->id
            });
    } elsif ( $i%4 == 3 ) {
        $change = $contact->change (
            $account,
            'request',
            {
                name => 'Name Two' . $i,
                email => 'Email Two' . $i,
                address => $address2->id
            });
    }

    #what's the faith of this change?
    my $freetext = '';

    if ($i%2 == 0) {
        $freetext = 'Freetext' . $i;
    }


    if ( $i%3 == 1 ) {
        $change->approve ($adminaccount, $freetext);
    } elsif ( $i%3 == 2 ) {
        $change->reject ( $adminaccount, $freetext);
    }

    #groups
    my $group;

    my @types = ("informal","corporation","education","government","nfp","internal");
    my $type = $types[ $i%6 ];

    if ($i%2 == 0) {
        $group = $group_rs->create({
            account => $account,
            group_type => 'informal',
            group_name => 'group' . $i,
            url => 'http://group' . $i . '.example.com'
        });
    } else {
        $group = $group_rs->create({
            account => $account,
            group_type => $type,
            group_name => 'group' . $i,
            url => 'http://group' . $i . '.example.com',
            address => $address->id
        });
    }

    my $group2 = $group_rs->create({
            account => $account,
            group_type => $type,
            group_name => 'group02' . $i,
            url => 'http://group02' . $i . '.example.com'
        });

    my $group3 = $group_rs->create({
            account => $account,
            group_type => $type,
            group_name => 'group03' . $i,
            url => 'http://group03' . $i . '.example.com'
        });



    if ($i%4 == 0) { #auto verification succeeds!
        $group->change ($account, 'workflow_change', { status => 'pending_auto' } );
    } elsif ( $i%4 == 1 ) {
        $group->add_to_group_verifications ({ verification_type => 'freetext', verification_data => 'freetext' . $i });
        $group->change ($account, 'workflow_change', { status => 'pending_staff'});
    }

    if ( $group->status->is_pending_staff ) {

       if ( $i%2 == 0 ) {
           $group->verify ( $adminaccount, $freetext);
       }
    }

    if ( $group->status->is_pending_auto || $group->status->is_pending_staff ) {
        if ( $i%3 == 0 ) {
           $group->approve ( $adminaccount, $freetext );
        } elsif ($i%3 == 1) {
           $group->reject ( $adminaccount, $freetext);
        }
    }

    $group2->change ($account, 'workflow_change', { status => 'pending_staff'});
    $group2->approve ( $adminaccount );

    $group3->change ($account, 'workflow_change', { status => 'pending_staff'});
    $group3->approve ( $adminaccount );

    #group contact changes
    my $gc = $group2->invite_contact ( $adminaccount->contact, $account->id );

    if ( $i % 6 < 4 ) {
        $gc->accept_invitation();
    } elsif ( $i % 6 >= 5 ) {
        $gc->decline_invitation();
    }

    $gc = $group2->add_contact ($contact, $adminaccount->id);

    if ( $i%3 == 0 ) {
        $change = $gc->change(
            $account,
            'request',
            {
                'status' => 'retired'
            });
    } elsif ( $i%3 == 1 ) {
        $change = $gc->change(
            $account,
            'request',
            {
                'primary' => 0
            });
    } else {
        $change = $gc->change(
            $account,
            'request',
            {
                'status'  => 'retired',
                'primary' => 0
            });
    }

    if ( $i%3 == 1 ) {
        $change->approve ( $adminaccount, $freetext );
    } elsif ( $i%3 == 2 ) {
        $change->approve ( $adminaccount, $freetext );
    }

    #channel namespaces

    $group2->add_to_channel_namespaces ({ 'group_id' => $group2->id, 'account' => $account, 'namespace' => 'group' . $i, 'status' => 'active' });

    my $namespace = $group2->add_to_channel_namespaces ({ 'group_id' => $group2->id, 'account' => $account, 'namespace' => 'namespace' . $i });

    if ( $i%3 == 1 ) {
        $namespace->approve ( $adminaccount, $freetext );
    } elsif ( $i%3 == 2 ) {
        $namespace->reject ( $adminaccount, $freetext );
    }

    if ( $namespace->status->is_active ) {
        #channel namespace changes
        if ( $i%3 == 0 ) {
            $change = $namespace->change(
                $account,
                'request',
                {
                    'status' => 'deleted'
                });
        } elsif ( $i%3 == 1 ) {
            $change = $namespace->change(
                $account,
                'request',
                {
                    'group_id' => $group3->id
                });
        } else {
            $change = $namespace->change(
                $account,
                'request',
                {
                    'status'  => 'deleted',
                    'group_id' => $group3->id
                });
        }

        if ( $i%4 == 1 ) {
            $change->approve ( $adminaccount, $freetext );
        } elsif ( $i%4 >= 2 ) {
            $change->reject ( $adminaccount, $freetext );
        }
    }

    #cloak namespaces

    $group2->add_to_cloak_namespaces ({ 'group_id' => $group2->id, 'account' => $account, 'namespace' => 'group' . $i, 'status' => 'active' });
    $namespace = $group2->add_to_cloak_namespaces ({ 'group_id' => $group2->id, 'account' => $account, 'namespace' => 'namespace' . $i });

    if ( $i%3 == 1 ) {
        $namespace->approve ( $adminaccount, $freetext );
    } elsif ( $i%3 == 2 ) {
        $namespace->reject ( $adminaccount, $freetext );
    }

    if ( $namespace->status->is_active ) {
        #cloak namespace changes
        if ( $i%3 == 0 ) {
            $change = $namespace->change(
                $account,
                'request',
                {
                    'status' => 'deleted'
                });
        } elsif ( $i%3 == 1 ) {
            $change = $namespace->change(
                $account,
                'request',
                {
                    'group_id' => $group3->id
                });
        } else {
            $change = $namespace->change(
                $account,
                'request',
                {
                    'status'  => 'deleted',
                    'group_id' => $group3->id
                });
        }

        if ( $i%4 == 1 ) {
            $change->approve ( $adminaccount, $freetext );
        } elsif ( $i%4 >= 2 ) {
            $change->reject ( $adminaccount, $freetext );
        }
    }

    #channel requests
    my $request;

    if ( $i%2 == 0 ) {
        $request = $request_rs->create ({
                requestor => $account->contact->id,
                channel => '#group' . $i,
                namespace => 'group' . $i,
                group => $group2,
                request_type => 'transfer',
                target => $account->id,
                changed_by => $account->id,
            });
    } else {
        $request = $request_rs->create ({
                requestor => $account->contact->id,
                channel => '#group' . $i,
                namespace => 'group' . $i,
                group => $group2,
                request_type => 'drop',
                target => $account->id,
                changed_by => $account->id,
            });
    }

    if ($i%3 == 0) {
        $request->apply ($adminaccount, $freetext);
    } elsif ($i%3 == 1) {
        $request->reject ($adminaccount, $freetext);
    }

    #cloaks
    my $cloak = $cloak_rs->create ({ target => $account->id, cloak => "group$i/user$i", changed_by => $account });

    if ($i%6 <= 2) {
        $cloak->apply ($adminaccount, $freetext);
    } elsif ($i%6 <= 4) {
        $cloak->accept ( $account->id );
    } elsif ($i%6 > 5) {
        $cloak->reject ($adminaccount, $freetext);
    }

    #group changes
    if ( $i%5 == 0 ) {
      $change = $group2->change(
          $account,
          'request',
          {
              'group_type' => $types [$i%6]
          });
    } elsif ( $i%5 == 1 ) {
      $change = $group2->change(
          $account,
          'request',
          {
              'url' => 'groupchange' . $i . '.example.com'
          });
    } elsif ( $i%5 == 2 ) {
      $change = $group2->change(
          $account,
          'request',
          {
              'address' => $address2->id
          });
    } elsif ($i%5 == 3 ) {
      $change = $group2->change(
          $account,
          'request',
          {
              'status' => 'deleted'
          });
    } else {
      $change = $group2->change(
          $account,
          'request',
          {
              'group_type' => $types [$i%6],
              'url' => 'groupchange' . $i . '.example.com',
              'address' => $address2->id,
              'status' => 'deleted'
          });
    }

    if ( $i%3 == 0 ) {
      $change->approve ( $adminaccount, $freetext );
    } elsif ($i%3 == 1) {
      $change->reject ( $adminaccount, $freetext );
    }
}

1;
