use utf8;
package Taipan::Schema::Result::Timezone;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Timezone

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

=head1 TABLE: C<timezone>

=cut

__PACKAGE__->table("timezone");

=head1 ACCESSORS

=head2 zone_id

  data_type: 'integer'
  is_nullable: 0

=head2 abbreviation

  data_type: 'text'
  is_nullable: 0

=head2 time_start

  data_type: 'integer'
  is_nullable: 0

=head2 gmt_offset

  data_type: 'integer'
  is_nullable: 0

=head2 dst

  data_type: 'char'
  is_nullable: 0
  size: 1

=cut

__PACKAGE__->add_columns(
  "zone_id",
  { data_type => "integer", is_nullable => 0 },
  "abbreviation",
  { data_type => "text", is_nullable => 0 },
  "time_start",
  { data_type => "integer", is_nullable => 0 },
  "gmt_offset",
  { data_type => "integer", is_nullable => 0 },
  "dst",
  { data_type => "char", is_nullable => 0, size => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6pQOqbSOBvOOSRIGaHkY/w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
