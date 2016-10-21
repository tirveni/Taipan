#!/usr/bin/perl -w
#
# Class::Ztime
#
# 2017-05-28
#
package Class::Tvals;

use Moose;
use namespace::autoclean;

use TryCatch;
use DateTime;

use Class::Utils qw(trim unxss valid_date redis_save_hash_field);

my ($o_redis,$c_prefix_key_tval,$c_expire_ina_day,
    $err_new_object,$err_new_creation);
{
  $o_redis		= Class::Utils::get_redis;
  $c_prefix_key_tval	= $Class::Rock::red_prefix_has_tval;
  $c_expire_ina_day	= $Class::Rock::seconds_day || 86401;
}

=pod

=head1 NAME

Class::Tvals - Utilities for handling TypeVals

=head1 SYNOPSIS

    use Class::Tvals;
    $o_tvals	= Class::Tvals->new(dtable,tableuniq,cfield);
    $value       = $o_tvals->cvalue;


Entity Attribute Model

https://en.wikipedia.org/wiki/Entity-attribute-value_model


=head1 METHODS

=over

=item B<new( $dtable,table_uniq,cfield )>

Return: the Class::Tvals object, or undef if the could not be found in Redis

=cut


sub new
{
  my $class	=	shift;
  my $dtable	=	shift;
  my $tuniq	=	shift;
  my $cfield	=	shift;

  my $m = "C/tvals->new";

  {
    $dtable = trim($dtable);
    $tuniq  = trim($tuniq);
    $cfield = trim($cfield);
  }

  my $red_key;
  if ($dtable && $tuniq && $cfield)
  {
    $red_key = "$c_prefix_key_tval:$dtable:$tuniq:$cfield";
  }

  my $already_existing =
      $o_redis->hexists($red_key,'cfield');

  ##Still Doesn't Exist;
  if (!$already_existing)
  {
    ##Nothing If Row is also not available
    return undef;
  }

  my $self = bless( {}, $class );
  $self->{data}		= $red_key;

  return ($self);

}


=head2 red_set_tvals($row_tval)

Arguments($row_bizapp)

=cut

sub red_set_tvals
{
  my $row_tv = shift;

  my $fn = "C/tvals::red_set_tvals";

  my ($dtable,$tableuniq,$cfield,$cvalue,$desc,$valid,$internal);
  $dtable	= trim($row_tv->dtable);
  $tableuniq	= trim($row_tv->tableuniq);
  $cfield	= trim($row_tv->cfield);

  my $red_key = "$c_prefix_key_tval:$dtable:$tableuniq:$cfield";

  {
    ##--- Hash

    my %rowh = $row_tv->get_columns();

    foreach my $column (keys %rowh)
    {
      # do whatever you want with $key and $value here ...
      my $value	= $rowh{$column};
      $value	= trim($value);

      #print "$fn $red_key=>$column/$value.\n";
      Class::Utils::redis_save_hash_field($o_redis,$red_key,$column,$value);
    }

    $o_redis->expire($red_key,$c_expire_ina_day);

  }

  my $o_tval = Class::Tvals->new($dtable,$tableuniq,$cfield);
  #print "$fn o_tval: $o_tval ($red_key) \n";

  return $o_tval;
}


=sub get_tvals($dbic,$table_name,$uniq_val,{internal,valid})

Returns: Array of Hash($o_tvals)

=cut

sub get_tvals
{
  my $dbic		= shift;
  my $table_name	= shift;
  my $uniq_val		= shift;
  my $h_src		= shift;

  my ($is_internal,$is_valid);
  {
    $is_internal = $h_src->{internal};
    $is_valid    = $h_src->{is_valid};
  }

  my $fn = "C/tvals/get_tvals";
  my $rs_tvals = $dbic->resultset('Typevalue');
  print "$fn Tvals:Begin \n";

  if ($table_name && $uniq_val)
  {
    $rs_tvals = $rs_tvals->search
      (
       {
	dtable		=> $table_name,
	tableuniq	=> $uniq_val,
       }
      );
  }

  if ( $is_internal && ($is_internal eq 't' )&& defined($rs_tvals))
  {
    $rs_tvals = $rs_tvals->search({internal=> $is_internal});
  }
  elsif ($is_internal && ($is_internal eq 'f' )&& defined($rs_tvals))
  {
    $rs_tvals = $rs_tvals->search({internal=> $is_internal});
  }


  if ($is_valid && ($is_valid eq 't') && defined($rs_tvals))
  {
    $rs_tvals = $rs_tvals->search({valid=> $is_valid});
  }
  elsif ( $is_valid && ($is_valid eq 'f' )&& defined($rs_tvals))
  {
    $rs_tvals = $rs_tvals->search({internal=> $is_valid});
  }

  print "$fn Tvals: $rs_tvals \n";

  my @list;
  while (my $row_tv = $rs_tvals->next())
  {
    my $o_tval = Class::Tvals::red_set_tvals($row_tv);
    print "$fn o_tval: $o_tval  \n";

    push(@list,$o_tval);
  }

  return \@list;

}


=head1 ACCESSORS

=head2 dtable

Returns: dtable of the Tval

=cut

sub dtable
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'dtable';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}


=head2 tableuniq

Returns: tableuniq of the Tval

=cut

sub tableuniq
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'tableuniq';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}

=head2 cfield

Returns: cfield of the Tval

=cut

sub cfield
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'cfield';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}

=head2 cvalue

Returns: cvalue of the Tval

=cut

sub cvalue
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'cvalue';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}


=head2 ctype

Returns: ctype of the Tval

=cut

sub ctype
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'ctype';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}


=head2 description

Returns: description of the Tval

=cut

sub description
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'description';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}

=head2 valid

Returns: valid of the Tval

=cut

sub valid
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'valid';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}

=head2 internal

Returns: internal of the Tval

=cut

sub internal
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'internal';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}

=head1

=head2 set_tvals

Sets the Message in the Redis Hash

Argument: DBIC

This is a set(array) of Roles.

=cut

sub set_tvals
{
  my $dbic = shift;

  my $rs_tvals = $dbic->resultset('Typevalue');

  my @list;
  while (my $row = $rs_tvals->next())
  {
    red_set_tvals($row);
  }

}


=back


=end


=back

=cut

1;
