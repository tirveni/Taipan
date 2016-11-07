use utf8;
package Taipan::Schema::Result::Access;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Access

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

=head1 TABLE: C<access>

=cut

__PACKAGE__->table("access");

=head1 ACCESSORS

=head2 privilege

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 role

  data_type: 'char'
  is_nullable: 0
  size: 8

=cut

__PACKAGE__->add_columns(
  "privilege",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "role",
  { data_type => "char", is_nullable => 0, size => 8 },
);

=head1 PRIMARY KEY

=over 4

=item * L</role>

=item * L</privilege>

=back

=cut

__PACKAGE__->set_primary_key("role", "privilege");

=head1 RELATIONS

=head2 privilege

Type: belongs_to

Related object: L<Taipan::Schema::Result::Privilege>

=cut

__PACKAGE__->belongs_to(
  "privilege",
  "Taipan::Schema::Result::Privilege",
  { privilege => "privilege" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2016-11-07 22:05:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eFB2j5U5edEUhMvoxxh23A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
