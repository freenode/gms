#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use GMS::Schema;
use GMS::Config;

use LWP::UserAgent;
use HTTP::Request;

my $ua = LWP::UserAgent->new;
$ua->agent('GMS/0.1');

my $db = GMS::Schema->connect($GMS::Config::dbstring,
    $GMS::Config::dbuser, $GMS::Config::dbpass);

my $rs = $db->resultset('Group');

use Data::Dumper;

foreach my $group ( $rs->search( { status => 'auto_pending' } ) )
{
    last if !$group;

    my $url = $group->verify_url;
    my $token = $group->verify_token;

    my $req = HTTP::Request->new(GET => "$url");
    my $res = $ua->request($req);

    if ($res->is_success)
    {
        if (-1 != index($res->content, $token))
        {
            $group->verify;
            print "Found verification token for pending group " . $group->groupname . "; marking verified\n";
        }
        else
        {
            print "Couldn't find verification token for group " . $group->groupname . "\n";
        }
    }
    else
    {
        print "Couldn't fetch verification URL for group " . $group->groupname . "\n";
    }
}


