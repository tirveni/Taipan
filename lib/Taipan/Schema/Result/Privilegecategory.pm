use utf8;
package Taipan::Schema::Result::Privilegecategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Privilegecategory

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

=head1 TABLE: C<privilegecategory>

=cut

__PACKAGE__->table("privilegecategory");

=head1 ACCESSORS

=head2 category

  data_type: 'char'
  is_nullable: 0
  size: 10

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "category",
  { data_type => "char", is_nullable => 0, size => 10 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</category>

=back

=cut

__PACKAGE__->set_primary_key("category");

=head1 RELATIONS

=head2 privileges

Type: has_many

Related object: L<Taipan::Schema::Result::Privilege>

=cut

__PACKAGE__->has_many(
  "privileges",
  "Taipan::Schema::Result::Privilege",
  { "foreign.category" => "self.category" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2016-11-07 22:05:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BO/oza5KeNQaYLIaO9B0bw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
