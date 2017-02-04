use utf8;
package Taipan::Schema::Result::Usernotified;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Usernotified

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

=head1 TABLE: C<usernotified>

=cut

__PACKAGE__->table("usernotified");

=head1 ACCESSORS

=head2 notifyid

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 userid

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 tried

  data_type: 'smallint'
  is_nullable: 1

=head2 user_confirmation

  data_type: 'boolean'
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
  "notifyid",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "userid",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "tried",
  { data_type => "smallint", is_nullable => 1 },
  "user_confirmation",
  { data_type => "boolean", is_nullable => 1 },
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

=item * L</notifyid>

=item * L</userid>

=back

=cut

__PACKAGE__->set_primary_key("notifyid", "userid");

=head1 RELATIONS

=head2 notifyid

Type: belongs_to

Related object: L<Taipan::Schema::Result::Notification>

=cut

__PACKAGE__->belongs_to(
  "notifyid",
  "Taipan::Schema::Result::Notification",
  { notifyid => "notifyid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
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

=head2 userid

Type: belongs_to

Related object: L<Taipan::Schema::Result::Appuser>

=cut

__PACKAGE__->belongs_to(
  "userid",
  "Taipan::Schema::Result::Appuser",
  { userid => "userid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-02-04 17:34:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Dp3VqIuw0S5y4Ah0HIHZTA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
