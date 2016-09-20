package Taipan::Schema::Result::Role;

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

Taipan::Schema::Result::Role

=cut

__PACKAGE__->table("roles");

=head1 ACCESSORS

=head2 role

  data_type: 'char'
  is_nullable: 0
  size: 8

=head2 level

  data_type: 'smallint'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "role",
  { data_type => "char", is_nullable => 0, size => 8 },
  "level",
  { data_type => "smallint", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("role");

=head1 RELATIONS

=head2 appusers

Type: has_many

Related object: L<Taipan::Schema::Result::Appuser>

=cut

__PACKAGE__->has_many(
  "appusers",
  "Taipan::Schema::Result::Appuser",
  { "foreign.role" => "self.role" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2016-09-20 16:29:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nGdkjJs9/2QLjnjSX6plKA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
