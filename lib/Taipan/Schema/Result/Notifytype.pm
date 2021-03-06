use utf8;
package Taipan::Schema::Result::Notifytype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Notifytype

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

=head1 TABLE: C<notifytype>

=cut

__PACKAGE__->table("notifytype");

=head1 ACCESSORS

=head2 notifytype

  data_type: 'char'
  is_nullable: 0
  size: 24

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "notifytype",
  { data_type => "char", is_nullable => 0, size => 24 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</notifytype>

=back

=cut

__PACKAGE__->set_primary_key("notifytype");

=head1 RELATIONS

=head2 notifications

Type: has_many

Related object: L<Taipan::Schema::Result::Notification>

=cut

__PACKAGE__->has_many(
  "notifications",
  "Taipan::Schema::Result::Notification",
  { "foreign.type" => "self.notifytype" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-02-04 18:56:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4GfJM86v3+y9Wpbmwg3Z9A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
