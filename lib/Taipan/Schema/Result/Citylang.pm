use utf8;
package Taipan::Schema::Result::Citylang;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Citylang

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

=head1 TABLE: C<citylang>

=cut

__PACKAGE__->table("citylang");

=head1 ACCESSORS

=head2 city_country

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 3

=head2 city_state

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 3

=head2 citycode

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 languagetype

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 4

=head2 cityname

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "city_country",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 3 },
  "city_state",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 3 },
  "citycode",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "languagetype",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 4 },
  "cityname",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</city_country>

=item * L</city_state>

=item * L</citycode>

=item * L</languagetype>

=back

=cut

__PACKAGE__->set_primary_key("city_country", "city_state", "citycode", "languagetype");

=head1 RELATIONS

=head2 city

Type: belongs_to

Related object: L<Taipan::Schema::Result::City>

=cut

__PACKAGE__->belongs_to(
  "city",
  "Taipan::Schema::Result::City",
  {
    city_country => "city_country",
    city_state   => "city_state",
    citycode     => "citycode",
  },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 languagetype

Type: belongs_to

Related object: L<Taipan::Schema::Result::Languagetype>

=cut

__PACKAGE__->belongs_to(
  "languagetype",
  "Taipan::Schema::Result::Languagetype",
  { code => "languagetype" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KyXS7OnWfc6/TiRzgjPucw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
