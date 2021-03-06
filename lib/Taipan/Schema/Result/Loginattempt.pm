use utf8;
package Taipan::Schema::Result::Loginattempt;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Loginattempt

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

=head1 TABLE: C<loginattempts>

=cut

__PACKAGE__->table("loginattempts");

=head1 ACCESSORS

=head2 ip_address

  data_type: 'text'
  is_nullable: 0

=head2 userid

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 date

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 tried_userid

  data_type: 'text'
  is_nullable: 1

=head2 login_success

  data_type: 'boolean'
  is_nullable: 1

=head2 comments

  data_type: 'text'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 0

=head2 user_agent

  data_type: 'text'
  is_nullable: 1

=head2 url

  data_type: 'text'
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

=cut

__PACKAGE__->add_columns(
  "ip_address",
  { data_type => "text", is_nullable => 0 },
  "userid",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "date",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "tried_userid",
  { data_type => "text", is_nullable => 1 },
  "login_success",
  { data_type => "boolean", is_nullable => 1 },
  "comments",
  { data_type => "text", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 0,
  },
  "user_agent",
  { data_type => "text", is_nullable => 1 },
  "url",
  { data_type => "text", is_nullable => 1 },
  "field1",
  { data_type => "text", is_nullable => 1 },
  "value1",
  { data_type => "text", is_nullable => 1 },
  "field2",
  { data_type => "text", is_nullable => 1 },
  "value2",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ip_address>

=item * L</created_at>

=back

=cut

__PACKAGE__->set_primary_key("ip_address", "created_at");

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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Gjxo7lBiIDPjA06WiDp+4Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
