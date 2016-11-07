use utf8;
package Taipan::Schema::Result::Logexception;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Logexception

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

=head1 TABLE: C<logexception>

=cut

__PACKAGE__->table("logexception");

=head1 ACCESSORS

=head2 exceptionid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'logexception_exceptionid_seq'

=head2 userid

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 type

  data_type: 'text'
  is_nullable: 1

=head2 reason

  data_type: 'text'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 1

=head2 field1

  data_type: 'text'
  is_nullable: 1

=head2 value1

  data_type: 'text'
  is_nullable: 1

=head2 field2

  data_type: 'text'
  is_nullable: 1

=head2 value2

  data_type: 'text'
  is_nullable: 1

=head2 field3

  data_type: 'text'
  is_nullable: 1

=head2 value3

  data_type: 'text'
  is_nullable: 1

=head2 field4

  data_type: 'text'
  is_nullable: 1

=head2 value4

  data_type: 'text'
  is_nullable: 1

=head2 field5

  data_type: 'text'
  is_nullable: 1

=head2 value5

  data_type: 'text'
  is_nullable: 1

=head2 field6

  data_type: 'text'
  is_nullable: 1

=head2 value6

  data_type: 'text'
  is_nullable: 1

=head2 field7

  data_type: 'text'
  is_nullable: 1

=head2 value7

  data_type: 'text'
  is_nullable: 1

=head2 field8

  data_type: 'text'
  is_nullable: 1

=head2 value8

  data_type: 'text'
  is_nullable: 1

=head2 field9

  data_type: 'text'
  is_nullable: 1

=head2 value9

  data_type: 'text'
  is_nullable: 1

=head2 entity

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "exceptionid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "logexception_exceptionid_seq",
  },
  "userid",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "type",
  { data_type => "text", is_nullable => 1 },
  "reason",
  { data_type => "text", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 1,
  },
  "field1",
  { data_type => "text", is_nullable => 1 },
  "value1",
  { data_type => "text", is_nullable => 1 },
  "field2",
  { data_type => "text", is_nullable => 1 },
  "value2",
  { data_type => "text", is_nullable => 1 },
  "field3",
  { data_type => "text", is_nullable => 1 },
  "value3",
  { data_type => "text", is_nullable => 1 },
  "field4",
  { data_type => "text", is_nullable => 1 },
  "value4",
  { data_type => "text", is_nullable => 1 },
  "field5",
  { data_type => "text", is_nullable => 1 },
  "value5",
  { data_type => "text", is_nullable => 1 },
  "field6",
  { data_type => "text", is_nullable => 1 },
  "value6",
  { data_type => "text", is_nullable => 1 },
  "field7",
  { data_type => "text", is_nullable => 1 },
  "value7",
  { data_type => "text", is_nullable => 1 },
  "field8",
  { data_type => "text", is_nullable => 1 },
  "value8",
  { data_type => "text", is_nullable => 1 },
  "field9",
  { data_type => "text", is_nullable => 1 },
  "value9",
  { data_type => "text", is_nullable => 1 },
  "entity",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</exceptionid>

=back

=cut

__PACKAGE__->set_primary_key("exceptionid");

=head1 RELATIONS

=head2 userid

Type: belongs_to

Related object: L<Taipan::Schema::Result::Appuser>

=cut

__PACKAGE__->belongs_to(
  "userid",
  "Taipan::Schema::Result::Appuser",
  { userid => "userid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2016-11-07 22:05:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BxekMEJvVkdHpdh8Vfcr0A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
