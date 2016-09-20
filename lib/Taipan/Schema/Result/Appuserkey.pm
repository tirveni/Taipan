package Taipan::Schema::Result::Appuserkey;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn");

=head1 NAME

Taipan::Schema::Result::Appuserkey

=cut

__PACKAGE__->table("appuserkey");

=head1 ACCESSORS

=head2 userid

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 key_guava

  data_type: 'text'
  is_nullable: 0

Used as key_guava or id/consumer_key/client_id

=head2 key_jamun

  data_type: 'text'
  is_nullable: 0

Used as key_jamun or key/consumer_secret/client_secret

=head2 valid_from

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 0

=head2 valid_till

  data_type: 'timestamp with time zone'
  is_nullable: 0

=head2 valid

  data_type: 'boolean'
  is_nullable: 1

=head2 ip

  data_type: 'text'
  is_nullable: 1

=head2 type

  data_type: 'char'
  default_value: 'API'
  is_nullable: 1
  size: 10

API: API access. TOKEN: Token access. Resource: temporary method access(exact method column is matched).

=head2 method

  data_type: 'text'
  is_nullable: 1

=head2 method_type

  data_type: 'char'
  is_nullable: 1
  size: 24

=head2 expiry

  data_type: 'timestamp with time zone'
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
  "userid",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "key_guava",
  { data_type => "text", is_nullable => 0 },
  "key_jamun",
  { data_type => "text", is_nullable => 0 },
  "valid_from",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 0,
  },
  "valid_till",
  { data_type => "timestamp with time zone", is_nullable => 0 },
  "valid",
  { data_type => "boolean", is_nullable => 1 },
  "ip",
  { data_type => "text", is_nullable => 1 },
  "type",
  { data_type => "char", default_value => "API", is_nullable => 1, size => 10 },
  "method",
  { data_type => "text", is_nullable => 1 },
  "method_type",
  { data_type => "char", is_nullable => 1, size => 24 },
  "expiry",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 1,
  },
  "update_userid",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("userid", "valid_from", "valid_till");
__PACKAGE__->add_unique_constraint(
  "appuserkey_key_guava_key_jamun_key",
  ["key_guava", "key_jamun"],
);

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2016-09-20 16:29:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FjY8rQFOJ31+VMrpItYmHA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
