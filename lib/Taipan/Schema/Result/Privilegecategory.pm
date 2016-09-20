package Taipan::Schema::Result::Privilegecategory;

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

Taipan::Schema::Result::Privilegecategory

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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2016-09-20 16:29:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/nu+OZqJ0Ar7p25NuKjm4g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
