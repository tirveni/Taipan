use utf8;
package Taipan::Schema::Result::CountryMore;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::CountryMore

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::EncodedColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn");

=head1 TABLE: C<country_more>

=cut

__PACKAGE__->table("country_more");

=head1 ACCESSORS

=head2 countrycode

  data_type: 'char'
  is_nullable: 0
  size: 2

=head2 currencycode

  data_type: 'char'
  is_nullable: 1
  size: 3

=head2 continent

  data_type: 'char'
  is_nullable: 1
  size: 2

=head2 iso3

  data_type: 'char'
  is_nullable: 1
  size: 3

=head2 isd

  data_type: 'text'
  is_nullable: 1

=head2 capital

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "countrycode",
  { data_type => "char", is_nullable => 0, size => 2 },
  "currencycode",
  { data_type => "char", is_nullable => 1, size => 3 },
  "continent",
  { data_type => "char", is_nullable => 1, size => 2 },
  "iso3",
  { data_type => "char", is_nullable => 1, size => 3 },
  "isd",
  { data_type => "text", is_nullable => 1 },
  "capital",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</countrycode>

=back

=cut

__PACKAGE__->set_primary_key("countrycode");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i0B+ioYrSxPcfJaO8KPYOA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
