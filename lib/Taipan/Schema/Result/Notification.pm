use utf8;
package Taipan::Schema::Result::Notification;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Notification

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

=head1 TABLE: C<notification>

=cut

__PACKAGE__->table("notification");

=head1 ACCESSORS

=head2 notifyid

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'notification_notifyid_seq'

=head2 type

  data_type: 'char'
  is_nullable: 1
  size: 24

=head2 message

  data_type: 'text'
  is_nullable: 1

=head2 active

  data_type: 'boolean'
  is_nullable: 1

=head2 user_confirmation

  data_type: 'boolean'
  is_nullable: 1

=head2 email_required

  data_type: 'boolean'
  is_nullable: 1

=head2 mobile_required

  data_type: 'boolean'
  is_nullable: 1

=head2 active_from

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 active_till

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 priority

  data_type: 'smallint'
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
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "notification_notifyid_seq",
  },
  "type",
  { data_type => "char", is_nullable => 1, size => 24 },
  "message",
  { data_type => "text", is_nullable => 1 },
  "active",
  { data_type => "boolean", is_nullable => 1 },
  "user_confirmation",
  { data_type => "boolean", is_nullable => 1 },
  "email_required",
  { data_type => "boolean", is_nullable => 1 },
  "mobile_required",
  { data_type => "boolean", is_nullable => 1 },
  "active_from",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "active_till",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "priority",
  { data_type => "smallint", is_nullable => 1 },
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

=back

=cut

__PACKAGE__->set_primary_key("notifyid");

=head1 RELATIONS

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

=head2 usernotifieds

Type: has_many

Related object: L<Taipan::Schema::Result::Usernotified>

=cut

__PACKAGE__->has_many(
  "usernotifieds",
  "Taipan::Schema::Result::Usernotified",
  { "foreign.notifyid" => "self.notifyid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-02-04 18:03:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FL7oqPNXEmuM++3R+Z/PmA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
