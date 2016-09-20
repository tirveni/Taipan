package Taipan::Model::TDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Taipan::Schema',
    
    connect_info => {
        dsn => 'dbi:Pg:dbname=taipan;host=localhost;',
        user => 'eloor',
        password => 'eloor',
        AutoCommit => q{1},
    }
);

=head1 NAME

Taipan::Model::TDB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Taipan>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Taipan::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.6

=head1 AUTHOR

Tirveni Yadav

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
