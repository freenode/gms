package GMS::Web::View::JSON;
use base qw( Catalyst::View::JSON );
use JSON::XS ();
use JSON -convert_blessed_universally;

sub encode_json {
    my( $self, $c, $data ) = @_;

    my $encoder = JSON::XS->new->utf8->pretty(0)->indent(0)
                      ->allow_blessed(1)->convert_blessed(1);

    $encoder->encode( $data );
}

__PACKAGE__->config(
    expose_stash  => qr/^json_/,
    allow_blessed => 1
);

=head1 NAME

GMS::Web::View::JSON - JSON View for GMS::Web

=head1 DESCRIPTION

JSON View for GMS::Web. 

=head1 SEE ALSO

L<GMS::Web>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
