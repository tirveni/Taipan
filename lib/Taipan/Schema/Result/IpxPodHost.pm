package Taipan::Schema::Result::IpxPodHost;

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

Taipan::Schema::Result::IpxPodHost

=cut

__PACKAGE__->table("ipx_pod_host");

=head1 ACCESSORS

=head2 podid

  data_type: 'char'
  is_nullable: 0
  size: 12

=head2 ip

  data_type: 'inet'
  is_nullable: 0

=head2 internal_ip

  data_type: 'inet'
  is_nullable: 1

=head2 priority

  data_type: 'smallint'
  is_nullable: 1

=head2 hostname

  data_type: 'text'
  is_nullable: 1

=head2 active

  data_type: 'boolean'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "podid",
  { data_type => "char", is_nullable => 0, size => 12 },
  "ip",
  { data_type => "inet", is_nullable => 0 },
  "internal_ip",
  { data_type => "inet", is_nullable => 1 },
  "priority",
  { data_type => "smallint", is_nullable => 1 },
  "hostname",
  { data_type => "text", is_nullable => 1 },
  "active",
  { data_type => "boolean", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("podid", "ip");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2016-09-20 16:29:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7x0Sl3kY9eQmn23HKeBQEQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
