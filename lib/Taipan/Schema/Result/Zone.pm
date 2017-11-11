use utf8;
package Taipan::Schema::Result::Zone;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Zone

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

=head1 TABLE: C<zone>

=cut

__PACKAGE__->table("zone");

=head1 ACCESSORS

=head2 zone_id

  data_type: 'integer'
  is_nullable: 0

=head2 countrycode

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 1
  size: 3

=head2 zone_name

  data_type: 'varchar'
  is_nullable: 0
  size: 35

=cut

__PACKAGE__->add_columns(
  "zone_id",
  { data_type => "integer", is_nullable => 0 },
  "countrycode",
  { data_type => "char", is_foreign_key => 1, is_nullable => 1, size => 3 },
  "zone_name",
  { data_type => "varchar", is_nullable => 0, size => 35 },
);

=head1 PRIMARY KEY

=over 4

=item * L</zone_name>

=back

=cut

__PACKAGE__->set_primary_key("zone_name");

=head1 UNIQUE CONSTRAINTS

=head2 C<i_zone_zone_id>

=over 4

=item * L</zone_id>

=back

=cut

__PACKAGE__->add_unique_constraint("i_zone_zone_id", ["zone_id"]);

=head1 RELATIONS

=head2 countrycode

Type: belongs_to

Related object: L<Taipan::Schema::Result::Country>

=cut

__PACKAGE__->belongs_to(
  "countrycode",
  "Taipan::Schema::Result::Country",
  { countrycode => "countrycode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Bqx+1aQHNyb4AZR6QvQP6Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
