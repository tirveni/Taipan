package Taipan::Schema::Result::Typevalue;

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

Taipan::Schema::Result::Typevalue

=cut

__PACKAGE__->table("typevalues");

=head1 ACCESSORS

=head2 dtable

  data_type: 'char'
  is_nullable: 0
  size: 24

=head2 tableuniq

  data_type: 'char'
  is_nullable: 0
  size: 24

=head2 cfield

  data_type: 'char'
  is_nullable: 0
  size: 24

=head2 cvalue

  data_type: 'char'
  is_nullable: 1
  size: 72

=head2 ctype

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 valid

  data_type: 'boolean'
  is_nullable: 1

=head2 internal

  data_type: 'boolean'
  is_nullable: 1

=head2 priority

  data_type: 'smallint'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 1

=head2 update_userid

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "dtable",
  { data_type => "char", is_nullable => 0, size => 24 },
  "tableuniq",
  { data_type => "char", is_nullable => 0, size => 24 },
  "cfield",
  { data_type => "char", is_nullable => 0, size => 24 },
  "cvalue",
  { data_type => "char", is_nullable => 1, size => 72 },
  "ctype",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "valid",
  { data_type => "boolean", is_nullable => 1 },
  "internal",
  { data_type => "boolean", is_nullable => 1 },
  "priority",
  { data_type => "smallint", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 1,
  },
  "update_userid",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("dtable", "tableuniq", "cfield");

=head1 RELATIONS

=head2 update_userid

Type: belongs_to

Related object: L<Taipan::Schema::Result::Appuser>

=cut

__PACKAGE__->belongs_to(
  "update_userid",
  "Taipan::Schema::Result::Appuser",
  { userid => "update_userid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2016-09-20 16:29:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kmmcRfnUBYFD4i7m6kYJ7g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
