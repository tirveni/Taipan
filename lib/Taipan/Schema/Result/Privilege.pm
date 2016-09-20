package Taipan::Schema::Result::Privilege;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn");

=head1 NAME

Taipan::Schema::Result::Privilege

=cut

__PACKAGE__->table("privilege");

=head1 ACCESSORS

=head2 privilege

  data_type: 'text'
  is_nullable: 0

=head2 category

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 type

  data_type: 'char'
  is_nullable: 1
  size: 16

=head2 appid

  data_type: 'char'
  is_nullable: 1
  size: 16

=cut

__PACKAGE__->add_columns(
  "privilege",
  { data_type => "text", is_nullable => 0 },
  "category",
  { data_type => "char", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "type",
  { data_type => "char", is_nullable => 1, size => 16 },
  "appid",
  { data_type => "char", is_nullable => 1, size => 16 },
);
__PACKAGE__->set_primary_key("privilege");

=head1 RELATIONS

=head2 accesses

Type: has_many

Related object: L<Taipan::Schema::Result::Access>

=cut

__PACKAGE__->has_many(
  "accesses",
  "Taipan::Schema::Result::Access",
  { "foreign.privilege" => "self.privilege" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 category

Type: belongs_to

Related object: L<Taipan::Schema::Result::Privilegecategory>

=cut

__PACKAGE__->belongs_to(
  "category",
  "Taipan::Schema::Result::Privilegecategory",
  { category => "category" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2016-09-20 16:29:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pVudH4gBoXrsdheumX17bA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
