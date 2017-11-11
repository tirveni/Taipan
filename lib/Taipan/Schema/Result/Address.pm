use utf8;
package Taipan::Schema::Result::Address;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Address

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

=head1 TABLE: C<address>

=cut

__PACKAGE__->table("address");

=head1 ACCESSORS

=head2 addressid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'address_addressid_seq'

=head2 streetaddress1

  data_type: 'text'
  is_nullable: 1

=head2 streetaddress2

  data_type: 'text'
  is_nullable: 1

=head2 streetaddress3

  data_type: 'text'
  is_nullable: 1

=head2 address_city

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 1
  size: 20

=head2 address_state

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 1
  size: 3

=head2 address_country

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 1
  size: 3

=head2 address_area

  data_type: 'char'
  is_nullable: 1
  size: 8

=head2 address_locality

  data_type: 'char'
  is_nullable: 1
  size: 8

=head2 addressverified

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 directions

  data_type: 'text'
  is_nullable: 1

=head2 priority

  data_type: 'integer'
  is_nullable: 1

=head2 pincode

  data_type: 'text'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "addressid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "address_addressid_seq",
  },
  "streetaddress1",
  { data_type => "text", is_nullable => 1 },
  "streetaddress2",
  { data_type => "text", is_nullable => 1 },
  "streetaddress3",
  { data_type => "text", is_nullable => 1 },
  "address_city",
  { data_type => "char", is_foreign_key => 1, is_nullable => 1, size => 20 },
  "address_state",
  { data_type => "char", is_foreign_key => 1, is_nullable => 1, size => 3 },
  "address_country",
  { data_type => "char", is_foreign_key => 1, is_nullable => 1, size => 3 },
  "address_area",
  { data_type => "char", is_nullable => 1, size => 8 },
  "address_locality",
  { data_type => "char", is_nullable => 1, size => 8 },
  "addressverified",
  { data_type => "char", is_nullable => 1, size => 1 },
  "directions",
  { data_type => "text", is_nullable => 1 },
  "priority",
  { data_type => "integer", is_nullable => 1 },
  "pincode",
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

=item * L</addressid>

=back

=cut

__PACKAGE__->set_primary_key("addressid");

=head1 RELATIONS

=head2 city

Type: belongs_to

Related object: L<Taipan::Schema::Result::City>

=cut

__PACKAGE__->belongs_to(
  "city",
  "Taipan::Schema::Result::City",
  {
    city_country => "address_country",
    city_state   => "address_state",
    citycode     => "address_city",
  },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZjrNSb0ubKiHDG5uLgatww


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
