use utf8;
package Taipan::Schema::Result::State;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::State

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

=head1 TABLE: C<state>

=cut

__PACKAGE__->table("state");

=head1 ACCESSORS

=head2 state_country

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 3

=head2 statecode

  data_type: 'char'
  is_nullable: 0
  size: 3

=head2 statename

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
  "state_country",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 3 },
  "statecode",
  { data_type => "char", is_nullable => 0, size => 3 },
  "statename",
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

=item * L</state_country>

=item * L</statecode>

=back

=cut

__PACKAGE__->set_primary_key("state_country", "statecode");

=head1 RELATIONS

=head2 cities

Type: has_many

Related object: L<Taipan::Schema::Result::City>

=cut

__PACKAGE__->has_many(
  "cities",
  "Taipan::Schema::Result::City",
  {
    "foreign.city_country" => "self.state_country",
    "foreign.city_state"   => "self.statecode",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 state_country

Type: belongs_to

Related object: L<Taipan::Schema::Result::Country>

=cut

__PACKAGE__->belongs_to(
  "state_country",
  "Taipan::Schema::Result::Country",
  { countrycode => "state_country" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 statelangs

Type: has_many

Related object: L<Taipan::Schema::Result::Statelang>

=cut

__PACKAGE__->has_many(
  "statelangs",
  "Taipan::Schema::Result::Statelang",
  {
    "foreign.state_country" => "self.state_country",
    "foreign.statecode"     => "self.statecode",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VK6Ro3X/XKXLNsm0ieMEWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
