#!/usr/bin/perl -w
#

package Class::Country;

use Moose;
use namespace::autoclean;

use TryCatch;

use Class::Utils qw(unxss redis_save_hash trim);


my ($c_prefix_key_country,$c_expire_ina_day,$o_redis,$c_expire_in_hour);
{

  $o_redis		= Class::Utils::get_redis;

  $c_prefix_key_country = $Class::Rock::red_prefix_has_country ;
  $c_expire_ina_day     = $Class::Rock::seconds_day	|| 86400;
  $c_expire_in_hour	= $Class::Rock::seconds_inhour ;
}

=pod

=head1 NAME

Class::Country - Utilities for handling country-related data. 

Hybrid of Redis and DBIC

=head1 SYNOPSIS

    use Class::Country;
    $c	= Class::Country->new( $dbic, $country );
    $row	= $c->country();
    $code	= $c->countrycode();
    $name	= $c->countryname();

=head1 METHODS

=over

=item B<new( $context, $countrycode )>

Accept a country (either as a Country Code or as a DBIx::Class::Row
object and create a fresh Class::Country object from it. A context
must be provided.

Return the Class::Country object, or undef if the Country couldn't be
found.

=cut


sub new
{
  my $class		= shift;
  my $dbic		= shift;
  my $arg_countrycode  = shift;

  my $m = "C/Country->new";

  my $row;
  $row    = $arg_countrycode;

  my ( $countrycode,$r_hash_country,$already_existing);
  print "$m $c_prefix_key_country \n";

  try  {

    if (ref($arg_countrycode))
    {
      $countrycode = $row->get_column('countrycode');
    }
    else
    {
      $countrycode = $arg_countrycode;
    }

    $countrycode = trim(unxss($arg_countrycode));

    $r_hash_country = "$c_prefix_key_country:$countrycode";
    print "$m Rkey: $r_hash_country Redis:($o_redis) \n";
    $already_existing = $o_redis->hexists($r_hash_country,'countrycode');

    if ($already_existing)
    {
      my $refresh_reqd = Class::Country::is_stale($countrycode);
      if ($refresh_reqd > 0)
      {
	$already_existing = undef;
      }##Comparison IF

    }

    if (!$already_existing)
    {
      my $in_h = {countrycode=>$countrycode};
      $row = Class::Country::get_dbrow($dbic,$countrycode);
      print "$m Row:$row \n";

      if (defined($row))
      {
	_red_set_country($row);

	$already_existing =
	  $o_redis->hexists($r_hash_country,'countrycode');
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
  $self->{data}		= $r_hash_country;
  $self->{redis}	= $o_redis;
  $self->{db_object}    = $dbic;

  print "$m End \n";

  return ($self);


}


=head2 db_object

=cut

sub db_object
{
  my $self      = shift;
  return ( $self->{db_object} );

}


=head2 is_stale

Returns: True if Older than an Hour.

=cut

sub is_stale
{
  my $countrycode      =  shift;

  my $r_hash_country	= "$c_prefix_key_country:$countrycode";
  my $f_updated		= 'updated_epoch';

  my $refresh_reqd	= 0;
  my $epoch_time	= time;
  my $seconds_in_hour	= 3600;

  my $local_epoch = $o_redis->hget($r_hash_country,$f_updated);

  my $older_than_hour = 0;
  if ($local_epoch)
  {
    my $local_plus_hour = ($local_epoch + 3600) ;
    $older_than_hour = 1
      if($local_plus_hour < $epoch_time);
  }

  if ($older_than_hour > 0)
  {
    $refresh_reqd = 1;
  }

  return $refresh_reqd;

}


=head1 REDIS Fx

=head2 get_dbrow

Function

Returns: the DBIx::Class::Row object for this DB Country.
Get the database object.

=cut

sub get_dbrow
{
  my $dbic		= shift;
  my $arg_countrycode	= shift;

  my $fn = "C/Country:get_dbrow";

  my $t_country = $dbic->resultset("Country");
  my $row;
  {
    $row	= $t_country->find
      (
       {
	  countrycode	=> $arg_countrycode, 
       }
      );
  }

  return ( $row );

}


=head2 _red_set_country($row_country)

Arguments: ($row_city)

For Edit:

=cut

sub _red_set_country
{
  my $row_country = shift;

  my $f = "C/City::red_set_country";
  print "$f Begin: $row_country  \n";

  if (!$row_country)
  {
    print "$f $row_country  \n";
    return undef;
  }

  my $row_cmore;
  my $dbic		= $row_country->result_source->schema;
  my $countrycode	= $row_country->get_column('countrycode');

  if ($countrycode && $dbic)
  {
    my $t_cm	= $dbic->resultset('CountryMore');	
    $row_cmore	= $t_cm->find({countrycode=>$countrycode});
    print "$f Country More:$row_cmore  \n";
  }
    print "$f More: $row_cmore \n";

  my $f_updated	= 'updated_epoch';
  my $r_hash_cc =
    "$c_prefix_key_country:$countrycode";

  my (%c_data,%cm_data);
  my @ignore_fields;
  {
    %c_data = $row_country->get_columns if(defined($row_country));
    push(@ignore_fields,'countrycode');
    %cm_data = $row_cmore->get_columns if(defined($row_cmore));
  }

  Class::Utils::redis_save_hash($o_redis,$r_hash_cc,\%c_data);
  Class::Utils::redis_save_hash($o_redis,$r_hash_cc,\%cm_data,\@ignore_fields);

  ##--Update Info:
  {
    my $epoch_time = time;
    $o_redis->hset($r_hash_cc,$f_updated,$epoch_time);
    $o_redis->expire($r_hash_cc,$c_expire_ina_day);
    ##Comment in Production

  }


  print "$f END  \n";


}

=back

=head1 ACCESSORS

=over

=head2 countrycode

Returns: code of Country

=cut

sub countrycode
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'countrycode';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  $value = trim($value);

  return $value;

}


=head2 countryname

Returns: Name of Country

=cut

sub countryname
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'countryname';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  $value = trim($value);

  return $value;

}

=head2 name

Returns: Name

=cut

sub name
{
  my $self  = shift;

  my $xvalue = $self->countryname;

  return $xvalue;

}




=head2 iso3

Returns: 3 Chars of CountryCode

=cut

sub iso3
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'iso3';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  $value = trim($value);

  return $value;

}


=head2 currencycode

Returns: CurrencyCode of Country

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

=head2 currency

Returns: CurrencyCode

=cut

sub currency
{
  my $self  = shift;

  my $xvalue = $self->currencycode;

  return $xvalue;

}



=head2 isd

Returns: ISD of Country

=cut

sub isd
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'isd';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  $value = trim($value);

  return $value;

}

=head2 capital

Returns: CAPITAL of Country

=cut

sub capital
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'capital';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  $value = trim($value);

  return $value;

}

=head2 continent

Returns: CONTINENT(char 2) of Country

=cut

sub continent
{
  my $self  = shift;
  my $in_val = shift || "";

  my $value;
  my $field = 'continent';
  my $datakey  = $self->{data};

  $value = $o_redis->hget($datakey,$field);
  $value = trim($value);

  return $value;

}

=head2 states($dbic)

Returns: HashRef{countrycode,countryname,statecode,statename}

=cut

sub states
{
  my $self	= shift;
  my $dbic	= shift;


  ##--
  if (!$dbic)
  {
    $dbic = $self->db_object;
  }

  my $country_code = $self->countrycode;
  my $country_name = $self->countryname;

  my $table_state  = $dbic->resultset('State');
  my $rs_states	   = $table_state->search({state_country=>$country_code});

  my @list;

  while ( my $row_state = $rs_states->next() )
  {
    my $st_name = trim($row_state->statename);
    my $st_code = trim($row_state->statecode);

    push(@list,
	 {
	  countrycode	=> $country_code,
	  countryname	=> $country_name,
	  statename	=> $st_name,
	  statecode	=> $st_code,
	 });


  }

  return \@list;

}


=end

=cut

1;
