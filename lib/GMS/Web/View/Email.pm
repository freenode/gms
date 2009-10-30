package GMS::Web::View::Email;

use strict;
use base 'Catalyst::View::Email::Template';

__PACKAGE__->config(
    stash_key       => 'email',
    template_prefix => 'email',
    default => {
        charset => 'utf-8',
        view => 'TT::Raw'
    }
);

=head1 NAME

GMS::Web::View::Email - Templated Email View for GMS::Web

=head1 DESCRIPTION

View for sending template-generated email from GMS::Web. 

=head1 AUTHOR

A clever guy

=head1 SEE ALSO

L<GMS::Web>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
