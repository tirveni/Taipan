use utf8;
package Taipan::Schema::Result::City;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::City

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

=head1 TABLE: C<city>

=cut

__PACKAGE__->table("city");

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
  is_nullable: 0
  size: 20

=head2 cityname

  data_type: 'text'
  is_nullable: 1

=head2 latitude

  data_type: 'text'
  is_nullable: 1

=head2 longitude

  data_type: 'text'
  is_nullable: 1

=head2 verified

  data_type: 'boolean'
  default_value: true
  is_nullable: 1

=head2 userid

  data_type: 'text'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "city_country",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 3 },
  "city_state",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 3 },
  "citycode",
  { data_type => "char", is_nullable => 0, size => 20 },
  "cityname",
  { data_type => "text", is_nullable => 1 },
  "latitude",
  { data_type => "text", is_nullable => 1 },
  "longitude",
  { data_type => "text", is_nullable => 1 },
  "verified",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
  "userid",
  { data_type => "text", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</city_country>

=item * L</city_state>

=item * L</citycode>

=back

=cut

__PACKAGE__->set_primary_key("city_country", "city_state", "citycode");

=head1 RELATIONS

=head2 addresses

Type: has_many

Related object: L<Taipan::Schema::Result::Address>

=cut

__PACKAGE__->has_many(
  "addresses",
  "Taipan::Schema::Result::Address",
  {
    "foreign.address_city"    => "self.citycode",
    "foreign.address_country" => "self.city_country",
    "foreign.address_state"   => "self.city_state",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 citylangs

Type: has_many

Related object: L<Taipan::Schema::Result::Citylang>

=cut

__PACKAGE__->has_many(
  "citylangs",
  "Taipan::Schema::Result::Citylang",
  {
    "foreign.city_country" => "self.city_country",
    "foreign.city_state"   => "self.city_state",
    "foreign.citycode"     => "self.citycode",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 state

Type: belongs_to

Related object: L<Taipan::Schema::Result::State>

=cut

__PACKAGE__->belongs_to(
  "state",
  "Taipan::Schema::Result::State",
  { state_country => "city_country", statecode => "city_state" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:daTJ0ZxtdO5/u6XHqCArfQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
