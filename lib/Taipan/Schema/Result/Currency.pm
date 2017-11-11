use utf8;
package Taipan::Schema::Result::Currency;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Currency

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

=head1 TABLE: C<currency>

=cut

__PACKAGE__->table("currency");

=head1 ACCESSORS

=head2 currencycode

  data_type: 'char'
  is_nullable: 0
  size: 3

=head2 currencyname

  data_type: 'text'
  is_nullable: 1

=head2 symbol

  data_type: 'char'
  is_nullable: 1
  size: 30

=head2 roundingfactor

  data_type: 'smallint'
  is_nullable: 1

=head2 country

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 1
  size: 2

=cut

__PACKAGE__->add_columns(
  "currencycode",
  { data_type => "char", is_nullable => 0, size => 3 },
  "currencyname",
  { data_type => "text", is_nullable => 1 },
  "symbol",
  { data_type => "char", is_nullable => 1, size => 30 },
  "roundingfactor",
  { data_type => "smallint", is_nullable => 1 },
  "country",
  { data_type => "char", is_foreign_key => 1, is_nullable => 1, size => 2 },
);

=head1 PRIMARY KEY

=over 4

=item * L</currencycode>

=back

=cut

__PACKAGE__->set_primary_key("currencycode");

=head1 RELATIONS

=head2 country

Type: belongs_to

Related object: L<Taipan::Schema::Result::Country>

=cut

__PACKAGE__->belongs_to(
  "country",
  "Taipan::Schema::Result::Country",
  { countrycode => "country" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-11-11 11:09:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Izwugx3a4RjgyB4frIpVcg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
