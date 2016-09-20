package Taipan::Schema::Result::Task;

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

Taipan::Schema::Result::Task

=cut

__PACKAGE__->table("task");

=head1 ACCESSORS

=head2 taskid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'task_taskid_seq'

=head2 maximum_tries

  data_type: 'smallint'
  is_nullable: 1

=head2 is_cron

  data_type: 'boolean'
  is_nullable: 1

=head2 cron_minute

  data_type: 'smallint'
  is_nullable: 1

=head2 cron_hour

  data_type: 'smallint'
  is_nullable: 1

=head2 cron_day_of_month

  data_type: 'smallint'
  is_nullable: 1

=head2 cron_month

  data_type: 'smallint'
  is_nullable: 1

=head2 cron_day_of_week

  data_type: 'smallint'
  is_nullable: 1

=head2 method

  data_type: 'text'
  is_nullable: 1

=head2 method_type

  data_type: 'char'
  is_nullable: 1
  size: 24

=head2 method_data

  data_type: 'text'
  is_nullable: 1

=head2 callback_method

  data_type: 'text'
  is_nullable: 1

=head2 callback_method_type

  data_type: 'text'
  is_nullable: 1

=head2 callback_method_data

  data_type: 'text'
  is_nullable: 1

=head2 userid

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 date_created

  data_type: 'timestamp with time zone'
  default_value: timezone('utc'::text, now())
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "taskid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "task_taskid_seq",
  },
  "maximum_tries",
  { data_type => "smallint", is_nullable => 1 },
  "is_cron",
  { data_type => "boolean", is_nullable => 1 },
  "cron_minute",
  { data_type => "smallint", is_nullable => 1 },
  "cron_hour",
  { data_type => "smallint", is_nullable => 1 },
  "cron_day_of_month",
  { data_type => "smallint", is_nullable => 1 },
  "cron_month",
  { data_type => "smallint", is_nullable => 1 },
  "cron_day_of_week",
  { data_type => "smallint", is_nullable => 1 },
  "method",
  { data_type => "text", is_nullable => 1 },
  "method_type",
  { data_type => "char", is_nullable => 1, size => 24 },
  "method_data",
  { data_type => "text", is_nullable => 1 },
  "callback_method",
  { data_type => "text", is_nullable => 1 },
  "callback_method_type",
  { data_type => "text", is_nullable => 1 },
  "callback_method_data",
  { data_type => "text", is_nullable => 1 },
  "userid",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "date_created",
  {
    data_type     => "timestamp with time zone",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 1,
  },
);
__PACKAGE__->set_primary_key("taskid");

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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2016-09-20 16:29:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YUeg+9soh18Ks19F8eBuVA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
