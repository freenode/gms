package Net::Atheme;

# $Id: Atheme.pm 610 2009-05-21 23:36:51Z davidp $

use warnings;
use strict;
use Carp;
use RPC::XML::Client;

=head1 NAME

Net::Atheme - interact with Atheme IRC services package

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

Provides an easy interface for interacting with the Atheme IRC services
package, as used by several networks including Freenode.


=head1 SYNOPSIS

    use Net::Atheme;

    # Log in and get a cookie, then whois somebody:
    my $atheme = Net::Atheme->new;
    if (my $cookie = $atheme->login($nick, $pass)) {
        my $result = $atheme->whois($nick);
    } else {
        die "Failed to log in";
    }

    # If you already have a cookie, you can pass it to the new object; this
    # means that calling ->login() is unnecessary (as long as the cookie
    # is still valid; if it's not, object creation will fail)
    my $foo = Net::Atheme->new( cookie => $cookie );



=head1 CONSTRUCTOR

Create a new Net::Atheme object.  Accepts a hash of options.

Options you may pass are:

=over 4

=item I<cookie> (optional)

Provide a cookie from a previous call to I<login> if you wish to re-use
that session, rather than having to call <login> yourself.

If you do not provide a cookie, you will need to call I<login>.

=item I<rpc_url> (required)

The URL to which XMLRPC requests should be dispatched.

For instance, http://somehost.example.com:8080/xmlrpc

=back

=cut

sub new {
    my ($class, %options) = @_;
    my $self = {};

    # Process recognised options and drop them in.  (Might need to extend
    # this later to validate them, or perform other actions when different
    # params are seen, hence the over-engineering)
    my @params = (
        { name => 'cookie' },
        { name => 'rpc_url', required => 1 },
    );
    for my $param (@params) {
        if ($param->{required} && !exists $options{$param}) {
            carp "Required parameter $param->{name} missing";
            return;
        }
        if (exists $options{$param->{name}}) {
            $self->{$param->{name}} = delete $options{$param->{name}};
        }
    }

    # Now, if we have anything left over that we weren't expecting:
    if (keys %options) {
        carp "Unrecognised params " . keys %options;
        return;
    }

    return bless $self, $class || __PACKAGE__;
}


=head1 METHODS

=head2 login($nick, $pass [, $source_ip])

Log in to Atheme services with a given nick and password.

In scalar context, returns a cookie to use for subsequent requests to reuse
this Atheme session, or undef for failure.

In list context, returns ($cookie, $error).

=cut

sub login {
    my ($self, $nick, $pass, $source_ip) = @_;

    my ($cookie, $error);

    my $result = $self->_rpc_client->simple_request(
        'atheme.login', $nick, $pass, $source_ip);

    if (ref $result) {
        # Something was wrong, say what
        return wantarray ?
            (undef, $result->{faultString} || 'Unknown RPC error') : undef;
    } elsif ($result) {
        # This is the cookie we want
        $self->{cookie} = $result;
        return wantarray ? ($result, undef) : $result;
    } else {
        # Empty response - ?!
        return wantarray ? (undef, "Empty response!") : undef;
    }
}


=head2 nick_info($nick)

Return information about the given nick

=cut

sub nick_info {
    my ($self, $nick) = @_;
    my $cookie = $self->_ensure_cookie or return;

    my ($resopnse) = $self->_rpc_client->simple_request(
        'atheme.command', $cookie, $user, '.', 'NickServ', 'INFO', $nick
    );


}


sub _ensure_cookie {
    my $self = shift;
    if (!$self->{cookie}) {
        carp "Attempting to make a request without a cookie - "
            ."must call login() or pass a cookie to constructor";
        return;
    }
    return $self->{cookie};
}

sub _rpc_client {
    my $self = shift;
    return $self->{_rpc_client} ||=
        RPC::XML::Client->new($self->{rpc_url});
}

=head1 AUTHOR

David Precious, C<< <davidp at preshweb.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-atheme at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Atheme>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Atheme


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Atheme>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Atheme>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Atheme>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Atheme/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 David Precious, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Net::Atheme
