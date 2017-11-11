use utf8;
package Taipan::Schema::Result::Statelang;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Statelang

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

=head1 TABLE: C<statelang>

=cut

__PACKAGE__->table("statelang");

=head1 ACCESSORS

=head2 state_country

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 3

=head2 statecode

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 3

=head2 statename

  data_type: 'text'
  is_nullable: 1

=head2 languagetype

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 4

=cut

__PACKAGE__->add_columns(
  "state_country",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 3 },
  "statecode",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 3 },
  "statename",
  { data_type => "text", is_nullable => 1 },
  "languagetype",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 4 },
);

=head1 PRIMARY KEY

=over 4

=item * L</state_country>

=item * L</statecode>

=item * L</languagetype>

=back

=cut

__PACKAGE__->set_primary_key("state_country", "statecode", "languagetype");

=head1 RELATIONS

=head2 languagetype

Type: belongs_to

Related object: L<Taipan::Schema::Result::Languagetype>

=cut

__PACKAGE__->belongs_to(
  "languagetype",
  "Taipan::Schema::Result::Languagetype",
  { code => "languagetype" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 state

Type: belongs_to

Related object: L<Taipan::Schema::Result::State>

=cut

__PACKAGE__->belongs_to(
  "state",
  "Taipan::Schema::Result::State",
  { state_country => "state_country", statecode => "statecode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 state_country

Type: belongs_to

Related object: L<Taipan::Schema::Result::Country>

=cut

__PACKAGE__->belongs_to(
  "state_country",
  "Taipan::Schema::Result::Country",
  { countrycode => "state_country" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:G2/6d3zKLl0n+0OgueGX+Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
