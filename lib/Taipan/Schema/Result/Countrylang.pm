use utf8;
package Taipan::Schema::Result::Countrylang;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Countrylang

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

=head1 TABLE: C<countrylang>

=cut

__PACKAGE__->table("countrylang");

=head1 ACCESSORS

=head2 countrycode

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 3

=head2 countryname

  data_type: 'text'
  is_nullable: 1

=head2 languagetype

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 4

=cut

__PACKAGE__->add_columns(
  "countrycode",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 3 },
  "countryname",
  { data_type => "text", is_nullable => 1 },
  "languagetype",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 4 },
);

=head1 PRIMARY KEY

=over 4

=item * L</countrycode>

=item * L</languagetype>

=back

=cut

__PACKAGE__->set_primary_key("countrycode", "languagetype");

=head1 RELATIONS

=head2 countrycode

Type: belongs_to

Related object: L<Taipan::Schema::Result::Country>

=cut

__PACKAGE__->belongs_to(
  "countrycode",
  "Taipan::Schema::Result::Country",
  { countrycode => "countrycode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XJn3KVRgIfols82CAQGijQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
