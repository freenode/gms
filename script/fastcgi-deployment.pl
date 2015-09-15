#!/usr/bin/perl
use warnings;
use strict;
use FindBin;

use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../deps/lib";
use lib "$FindBin::Bin/../deps/lib/perl5";

use Daemon::Control;

my $gms_dir  = $ENV{'GMSDIR'};
my $pid_dir  = $ENV{'PIDDIR'};
my $nprocs   = $ENV{'NPROCS'};
my $gms_user = $ENV{'GMSUSER'};

my $pid_file = "$pid_dir/gms.pid";

my $server = "$gms_dir/script/gms_web_fastcgi.pl";
my $socket = "$gms_dir/docroot/gms.sock";


exit Daemon::Control->new(
    name        => "GMS",
    lsb_start   => '$syslog $remote_fs',
    lsb_stop    => '$syslog',
    lsb_sdesc   => 'GMS Daemon',
    lsb_desc    => 'GMS Daemon starts and stops gms',

    program     => '/usr/bin/env',
    init_code   => "export GMSDIR=$gms_dir;
                    export PIDDIR=$pid_dir;
                    export NPROCS=$nprocs;
                    export GMSUSER=$gms_user;
                    export PERL5LIB=$FindBin::Bin/../lib:$FindBin::Bin/../lib/perl5/:$FindBin::Bin/../deps/lib:$FindBin::Bin/../deps/lib/perl5",
    program_args => [
        "perl",
        $server,
        "-l",
        $socket,
        "-p",
        $pid_file,
        "-n",
        $nprocs
    ],
    pid_file    => $pid_file,
    stderr_file => "/var/log/vhosts/localhost-gms/error/catalyst.log",
    stdout_file => "/var/log/vhosts/localhost-gms/log/catalyst.log",
    user        => $gms_user,

    fork        => 2,
)->run;

