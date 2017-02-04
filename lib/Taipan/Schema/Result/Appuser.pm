use utf8;
package Taipan::Schema::Result::Appuser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Taipan::Schema::Result::Appuser

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

=head1 TABLE: C<appuser>

=cut

__PACKAGE__->table("appuser");

=head1 ACCESSORS

=head2 userid

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 details

  data_type: 'text'
  is_nullable: 1

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 date_joined

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 1

=head2 active

  data_type: 'boolean'
  is_nullable: 1

=head2 role

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 1
  size: 8

=head2 dob

  data_type: 'date'
  is_nullable: 1

=head2 sex

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 email

  data_type: 'text'
  is_nullable: 1

=head2 verification_code

  data_type: 'text'
  is_nullable: 1

=head2 podid

  data_type: 'char'
  is_nullable: 1
  size: 12

=head2 phone

  data_type: 'char'
  is_nullable: 1
  size: 24

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "userid",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "details",
  { data_type => "text", is_nullable => 1 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "date_joined",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 1,
  },
  "active",
  { data_type => "boolean", is_nullable => 1 },
  "role",
  { data_type => "char", is_foreign_key => 1, is_nullable => 1, size => 8 },
  "dob",
  { data_type => "date", is_nullable => 1 },
  "sex",
  { data_type => "char", is_nullable => 1, size => 1 },
  "email",
  { data_type => "text", is_nullable => 1 },
  "verification_code",
  { data_type => "text", is_nullable => 1 },
  "podid",
  { data_type => "char", is_nullable => 1, size => 12 },
  "phone",
  { data_type => "char", is_nullable => 1, size => 24 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</userid>

=back

=cut

__PACKAGE__->set_primary_key("userid");

=head1 RELATIONS

=head2 appuserkey_update_userids

Type: has_many

Related object: L<Taipan::Schema::Result::Appuserkey>

=cut

__PACKAGE__->has_many(
  "appuserkey_update_userids",
  "Taipan::Schema::Result::Appuserkey",
  { "foreign.update_userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 appuserkey_userids

Type: has_many

Related object: L<Taipan::Schema::Result::Appuserkey>

=cut

__PACKAGE__->has_many(
  "appuserkey_userids",
  "Taipan::Schema::Result::Appuserkey",
  { "foreign.userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 languagetypes

Type: has_many

Related object: L<Taipan::Schema::Result::Languagetype>

=cut

__PACKAGE__->has_many(
  "languagetypes",
  "Taipan::Schema::Result::Languagetype",
  { "foreign.update_userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 logexceptions

Type: has_many

Related object: L<Taipan::Schema::Result::Logexception>

=cut

__PACKAGE__->has_many(
  "logexceptions",
  "Taipan::Schema::Result::Logexception",
  { "foreign.userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 loginattempts

Type: has_many

Related object: L<Taipan::Schema::Result::Loginattempt>

=cut

__PACKAGE__->has_many(
  "loginattempts",
  "Taipan::Schema::Result::Loginattempt",
  { "foreign.userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 notifications

Type: has_many

Related object: L<Taipan::Schema::Result::Notification>

=cut

__PACKAGE__->has_many(
  "notifications",
  "Taipan::Schema::Result::Notification",
  { "foreign.update_userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pagestaticlangs

Type: has_many

Related object: L<Taipan::Schema::Result::Pagestaticlang>

=cut

__PACKAGE__->has_many(
  "pagestaticlangs",
  "Taipan::Schema::Result::Pagestaticlang",
  { "foreign.update_userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pagestatics

Type: has_many

Related object: L<Taipan::Schema::Result::Pagestatic>

=cut

__PACKAGE__->has_many(
  "pagestatics",
  "Taipan::Schema::Result::Pagestatic",
  { "foreign.update_userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 role

Type: belongs_to

Related object: L<Taipan::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "Taipan::Schema::Result::Role",
  { role => "role" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 tagsofpages

Type: has_many

Related object: L<Taipan::Schema::Result::Tagsofpage>

=cut

__PACKAGE__->has_many(
  "tagsofpages",
  "Taipan::Schema::Result::Tagsofpage",
  { "foreign.update_userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tagtypes

Type: has_many

Related object: L<Taipan::Schema::Result::Tagtype>

=cut

__PACKAGE__->has_many(
  "tagtypes",
  "Taipan::Schema::Result::Tagtype",
  { "foreign.update_userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 typevalues

Type: has_many

Related object: L<Taipan::Schema::Result::Typevalue>

=cut

__PACKAGE__->has_many(
  "typevalues",
  "Taipan::Schema::Result::Typevalue",
  { "foreign.update_userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 usernotified_update_userids

Type: has_many

Related object: L<Taipan::Schema::Result::Usernotified>

=cut

__PACKAGE__->has_many(
  "usernotified_update_userids",
  "Taipan::Schema::Result::Usernotified",
  { "foreign.update_userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 usernotified_userids

Type: has_many

Related object: L<Taipan::Schema::Result::Usernotified>

=cut

__PACKAGE__->has_many(
  "usernotified_userids",
  "Taipan::Schema::Result::Usernotified",
  { "foreign.userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2017-02-04 17:34:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z6Uc93qgVzkzUiyHP0gZQQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
