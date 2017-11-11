use utf8;
package Taipan::Schema::Result::VCity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::VCity

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

=head1 TABLE: C<v_city>

=cut

__PACKAGE__->table("v_city");

=head1 ACCESSORS

=head2 citycode

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 cityname

  data_type: 'text'
  is_nullable: 1

=head2 city_country

  data_type: 'char'
  is_nullable: 1
  size: 3

=head2 city_state

  data_type: 'char'
  is_nullable: 1
  size: 3

=head2 statename

  data_type: 'text'
  is_nullable: 1

=head2 countryname

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "citycode",
  { data_type => "char", is_nullable => 1, size => 20 },
  "cityname",
  { data_type => "text", is_nullable => 1 },
  "city_country",
  { data_type => "char", is_nullable => 1, size => 3 },
  "city_state",
  { data_type => "char", is_nullable => 1, size => 3 },
  "statename",
  { data_type => "text", is_nullable => 1 },
  "countryname",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 20:20:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/uA6JWID0F56gaPt4jlATg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
