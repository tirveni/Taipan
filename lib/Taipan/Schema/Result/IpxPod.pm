use utf8;
package Taipan::Schema::Result::IpxPod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::IpxPod

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

=head1 TABLE: C<ipx_pod>

=cut

__PACKAGE__->table("ipx_pod");

=head1 ACCESSORS

=head2 podid

  data_type: 'char'
  is_nullable: 0
  size: 12

=head2 active

  data_type: 'boolean'
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "podid",
  { data_type => "char", is_nullable => 0, size => 12 },
  "active",
  { data_type => "boolean", is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</podid>

=back

=cut

__PACKAGE__->set_primary_key("podid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2016-11-10 17:46:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4TB35VOpgPI5eSu85pHH2w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
