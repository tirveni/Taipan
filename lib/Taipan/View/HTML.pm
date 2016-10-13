package Taipan::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,

    CATALYST_VAR => 'c',
    TIMER        => 0,
    ENCODING     => 'utf-8',
    WRAPPER => 'wrapper.tt',

);

=head1 NAME

Taipan::View::HTML - TT View for Taipan

=head1 DESCRIPTION

TT View for Taipan.

=head1 SEE ALSO

L<Taipan>

=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
