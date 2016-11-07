use utf8;
package Taipan::Schema::Result::Message;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Message

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

=head1 TABLE: C<message>

=cut

__PACKAGE__->table("message");

=head1 ACCESSORS

=head2 msgid

  data_type: 'integer'
  is_nullable: 0

=head2 type

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 message

  data_type: 'text'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "msgid",
  { data_type => "integer", is_nullable => 0 },
  "type",
  { data_type => "char", is_nullable => 1, size => 20 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "message",
  { data_type => "text", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</msgid>

=back

=cut

__PACKAGE__->set_primary_key("msgid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2016-11-07 22:05:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Y8Asy9wm7bmW07+ElTCAqA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
