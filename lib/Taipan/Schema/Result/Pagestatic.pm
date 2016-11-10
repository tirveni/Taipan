use utf8;
package Taipan::Schema::Result::Pagestatic;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Pagestatic

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

=head1 TABLE: C<pagestatic>

=cut

__PACKAGE__->table("pagestatic");

=head1 ACCESSORS

=head2 pageid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 pagename

  data_type: 'char'
  is_nullable: 1
  size: 24

=head2 content

  data_type: 'text'
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
  "pageid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "pagename",
  { data_type => "char", is_nullable => 1, size => 24 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 1,
  },
  "update_userid",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</pageid>

=back

=cut

__PACKAGE__->set_primary_key("pageid");

=head1 RELATIONS

=head2 pagestaticlangs

Type: has_many

Related object: L<Taipan::Schema::Result::Pagestaticlang>

=cut

__PACKAGE__->has_many(
  "pagestaticlangs",
  "Taipan::Schema::Result::Pagestaticlang",
  { "foreign.pageid" => "self.pageid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tagsofpages

Type: has_many

Related object: L<Taipan::Schema::Result::Tagsofpage>

=cut

__PACKAGE__->has_many(
  "tagsofpages",
  "Taipan::Schema::Result::Tagsofpage",
  { "foreign.pageid" => "self.pageid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2016-11-10 17:46:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dGo8BfFHf2k+0GwNe+AlMw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
