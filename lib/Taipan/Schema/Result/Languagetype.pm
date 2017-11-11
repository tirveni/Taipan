use utf8;
package Taipan::Schema::Result::Languagetype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Languagetype

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

=head1 TABLE: C<languagetype>

=cut

__PACKAGE__->table("languagetype");

=head1 ACCESSORS

=head2 code

  data_type: 'char'
  is_nullable: 0
  size: 4

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 path_of_icon

  data_type: 'text'
  is_nullable: 1

=head2 path_of_picture

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
  "code",
  { data_type => "char", is_nullable => 0, size => 4 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "path_of_icon",
  { data_type => "text", is_nullable => 1 },
  "path_of_picture",
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

=item * L</code>

=back

=cut

__PACKAGE__->set_primary_key("code");

=head1 RELATIONS

=head2 citylangs

Type: has_many

Related object: L<Taipan::Schema::Result::Citylang>

=cut

__PACKAGE__->has_many(
  "citylangs",
  "Taipan::Schema::Result::Citylang",
  { "foreign.languagetype" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 countrylangs

Type: has_many

Related object: L<Taipan::Schema::Result::Countrylang>

=cut

__PACKAGE__->has_many(
  "countrylangs",
  "Taipan::Schema::Result::Countrylang",
  { "foreign.languagetype" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pagestaticlangs

Type: has_many

Related object: L<Taipan::Schema::Result::Pagestaticlang>

=cut

__PACKAGE__->has_many(
  "pagestaticlangs",
  "Taipan::Schema::Result::Pagestaticlang",
  { "foreign.languagetype" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 statelangs

Type: has_many

Related object: L<Taipan::Schema::Result::Statelang>

=cut

__PACKAGE__->has_many(
  "statelangs",
  "Taipan::Schema::Result::Statelang",
  { "foreign.languagetype" => "self.code" },
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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hqBFj4FCYIVkJVNMMTinLg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
