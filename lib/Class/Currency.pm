#!/usr/bin/perl -w
#
# Copyright Tirveni Yadav, 2015-07-30.
# License: GPLv3
#


package Class::Currency;

use Moose;
use namespace::autoclean;
use Class::Utils qw(unxss trim);
use TryCatch;


has 'dbic' => (
  is => 'rw',
  required => 1,
  isa => 'DBIx::Class::Schema',
);

my ($o_redis,$c_prefix_key_currency,$c_expire_ina_day,
    $err_new_object,$err_new_creation);
{
  $o_redis			= Class::Utils::get_redis;
  $c_prefix_key_currency	= $Class::Rock::red_prefix_hash_currency;
  $c_expire_ina_day		= $Class::Rock::seconds_day || 86401;

}



=pod

=head1 NAME

Class::Currency - Utilities for handling currency-related data

Hybrid of Redis and DBIC.

=head1 SYNOPSIS

    use Class::Currency;
    $cc		= Class::Currency->new( $dbic, $currency_code );
    $row	= $cc->currency();
    $code	= $cc->currencycode();
    $name	= $cc->currencyname();

=head1 METHODS

=over

=item B<new( $context, $currency_code )>

Accept a currency (either as a Currency Code or as a DBIx::Class::Row
object and create a fresh Class::Currency object from it. A context
must be provided.

Return the Class::Currency object, or undef if the Currency couldn't be
found.

=cut

sub new
{
  my $class		= shift;
  my $dbic		= shift;
  my $arg_currencycode  = shift;

  my $m = "C/Currency->new";

  my $row;
  $row    = $arg_currencycode;

  my ( $currencycode,$r_hash_currency,$already_existing);
  print "$m $c_prefix_key_currency \n";

  try  {

    if (ref($arg_currencycode))
    {
      $currencycode = $row->get_column('currencycode');
    }
    else
    {
      $currencycode = $arg_currencycode;
    }

    $currencycode = trim(unxss($arg_currencycode));

    $r_hash_currency = "$c_prefix_key_currency:$currencycode";
    print "$m Rkey: $r_hash_currency Redis:($o_redis) \n";
    $already_existing = $o_redis->hexists($r_hash_currency,'currencycode');

    if ($already_existing)
    {
      my $refresh_reqd = Class::Currency::is_stale($currencycode);
      if ($refresh_reqd > 0)
      {
	$already_existing = undef;
      }##Comparison IF

    }

    if (!$already_existing)
    {
      my $in_h = {currencycode=>$currencycode};
      $row = Class::Currency::get_dbrow($dbic,$currencycode);
      #print "$m Row:$row \n";

      if (defined($row))
      {
	red_set_currency($row);

	$already_existing =
	  $o_redis->hexists($r_hash_currency,'currencycode');
      }

    }

    ##Still Doesn't Exist;
    if (!$already_existing)
    {
      ##Nothing If Row is also not available
      return undef;
    }


  }

  my $self = bless( {}, $class );
  $self->{data}		= $r_hash_currency;
  $self->{redis}	= $o_redis;
  $self->{db_object}    = $dbic;
  return ($self);


}

=head2 is_stale

Returns: True if Older than an Hour.

=cut

sub is_stale
{
  my $currencycode      =  shift;

  my $r_hash_currency	= "$c_prefix_key_currency:$currencycode";
  my $f_updated		= 'updated_epoch';

  my $refresh_reqd	= 0;
  my $epoch_time	= time;
  my $seconds_in_hour	= 3600;

  my $local_epoch = $o_redis->hget($r_hash_currency,$f_updated);

  my $older_than_hour = 0;
  if ($local_epoch)
  {
    my $local_plus_hour = ($local_epoch + 3600) ;
    $older_than_hour = 1
      if($local_plus_hour < $epoch_time);
  }

  #print "$m Local:$local_epoch,Central:$central_epoch \n";

  if ($older_than_hour > 0)
  {
    $refresh_reqd = 1;
  }

  return $refresh_reqd;

}


=head2 red_set_currency($row_currency)

Arguments($row_currency)

=cut

sub  red_set_currency
{
  my $row_currency = shift;

  my $fn = "B/currency::red_set_currency";

  my $f_cc   = 'currencycode';
  my $f_updated	= 'updated_epoch';
  my $epoch_time = time;

  my $v_cc   = $row_currency->get_column($f_cc);
  $v_cc      = trim($v_cc);

  if ($v_cc)
  {
    my $red_key = "$c_prefix_key_currency:$v_cc";

    my %rowh = $row_currency->get_columns();

    foreach my $column (keys %rowh)
    {
      # do whatever you want with $column and $value here ...
      my $value = $rowh{$column};
      $value    = trim($value);

      print "$fn =>$column/$value.\n";

      if (defined($value))
      {
	$o_redis->hset($red_key,$column,$value);
      }
      else
      {
	$o_redis->hdel($red_key,$column);
      }

    }

    $o_redis->hset($red_key,$f_updated,$epoch_time);
    $o_redis->expire($red_key,$c_expire_ina_day);

  }

}

=head2 get_dbrow($dbic,$currencycode)

Function Not a Method

Returns: the DBIx::Class::Row object for this DB Currency
Get the database object.

=cut

sub get_dbrow
{
  my $dbic                      = shift;
  my $arg_currencycode         = shift;

  my $fn = "B/Appuser::get_dbrow";

  my $rs_bizapp = $dbic->resultset("Currency");
  my $row;
  {
    $row        = $rs_bizapp->find
      (
       {
        currencycode   => $arg_currencycode,
       }
      );
  }
  #print "$fn $dbic Row:$row \n";
  return ( $row );

}


=back

=head1 ACCESSORS

=over

=head2 currencycode

Returns: Name of BizApp

=cut

sub currencycode
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'currencycode';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  $value = trim($value);

  return $value;

}

=head2 currency_code

Alias to CurrencyCode

=cut

sub currency_code
{
  my $self	=	shift;

  my $value = $self->currencycode;

  return $value;

}

=head2 currencyname

Returns: Name of BizApp

=cut

sub currencyname
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'currencyname';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  $value = trim($value);

  return $value;

}

=head2 currency_name

Alias to CurrencyName

=cut

sub currency_name
{
  my $self	=	shift;

  my $value = $self->currencyname;

  return $value;

}


=head2 symbol

Get/set the currency's Symbol

=cut

sub symbol
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'symbol';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  $value = trim($value);

  return $value;

}

=head2 roundingfactor

Get/set the currency's Roundingfactor

=cut
sub roundingfactor
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'roundingfactor';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}



=head2 country

Get/set the currency's Country

=cut

sub country
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'country';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  return $value;

}

=head2 get_currencies  ( $dbic [,$selected])

This Fn returns the Array of Hash of All the Currencies.

=cut

sub get_currencies
{
  my $dbic	= shift;
  my $in_code  = shift;

  my @list;
  my $rs_currencies = $dbic->resultset('Currency')->search
    (undef,{order_by => 'country'});
  my $f = "C/get_currencies";


  while ( my $row = $rs_currencies->next() )
  {
    my $currencyselected;

    my ($o_currency,$currencycode,$currencyname,$symbol);
    $currencycode	= trim($row->currencycode);
    $o_currency = Class::Currency->new($dbic,$currencycode);

    if ($o_currency)
    {
      $currencyname	= $o_currency->currencyname;
      $symbol		= $o_currency->currencysymbol;
    }

    my $currency_selected;
    if (($in_code) && $currencycode eq $in_code)
    {
      $currency_selected =
	"selected=\"selected\""; 
    }
    elsif(!$in_code && ($currencycode eq 'USD'))
    {
      $currency_selected =
	"selected=\"selected\""; 
    }

    push
      (@list,
       {
	currencycode	=> $currencycode,
	currencyname	=> $currencyname,
	selected	=> $currency_selected,
	symbol		=> $symbol,
       },
      );
  }				#while

  return @list;
}

1;

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
GPLv3. Copyright tirveni@udyansh.org

=cut
