use utf8;
package Taipan::Schema::Result::Country;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Country

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

=head1 TABLE: C<country>

=cut

__PACKAGE__->table("country");

=head1 ACCESSORS

=head2 countrycode

  data_type: 'char'
  is_nullable: 0
  size: 3

=head2 countryname

  data_type: 'text'
  is_nullable: 1

=head2 verified

  data_type: 'boolean'
  default_value: true
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "countrycode",
  { data_type => "char", is_nullable => 0, size => 3 },
  "countryname",
  { data_type => "text", is_nullable => 1 },
  "verified",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</countrycode>

=back

=cut

__PACKAGE__->set_primary_key("countrycode");

=head1 RELATIONS

=head2 countrylangs

Type: has_many

Related object: L<Taipan::Schema::Result::Countrylang>

=cut

__PACKAGE__->has_many(
  "countrylangs",
  "Taipan::Schema::Result::Countrylang",
  { "foreign.countrycode" => "self.countrycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 currencies

Type: has_many

Related object: L<Taipan::Schema::Result::Currency>

=cut

__PACKAGE__->has_many(
  "currencies",
  "Taipan::Schema::Result::Currency",
  { "foreign.country" => "self.countrycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 statelangs

Type: has_many

Related object: L<Taipan::Schema::Result::Statelang>

=cut

__PACKAGE__->has_many(
  "statelangs",
  "Taipan::Schema::Result::Statelang",
  { "foreign.state_country" => "self.countrycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 states

Type: has_many

Related object: L<Taipan::Schema::Result::State>

=cut

__PACKAGE__->has_many(
  "states",
  "Taipan::Schema::Result::State",
  { "foreign.state_country" => "self.countrycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 zones

Type: has_many

Related object: L<Taipan::Schema::Result::Zone>

=cut

__PACKAGE__->has_many(
  "zones",
  "Taipan::Schema::Result::Zone",
  { "foreign.countrycode" => "self.countrycode" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:C+bpkS0gTW9N55V6694paQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
