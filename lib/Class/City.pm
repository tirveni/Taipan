#!/usr/bin/perl -w
#
# Class/City.pm
#

package Class::City;

use Moose;
use namespace::autoclean;

use TryCatch;

=pod

=head1 NAME

Class::City - Utilities for handling city-related data

Hybrid of DBIC and REDIS for Local Cache

=head1 SYNOPSIS

    use Class::City;
    $o_cy = Class::City->new( $dbic, $countrycode, $statecode, $citycode );
    $city_code       = $o_cy->city_code

=head1 INHERITS

Class::City inherits from Class::State and Class::Country

=cut

#
# Parent classes.
use Class::Country;
use Class::State;
use Class::Utils  qw(unxss unxss_an chomp_date valid_date trim );

my ($o_redis,$c_expire_inan_hour);
my ($c_prefix_key_city);
{
  $o_redis = Class::Utils::get_redis;
  $c_expire_inan_hour = $Class::Rock::seconds_inhour || 3600;

  $c_prefix_key_city	=  $Class::Rock::red_prefix_has_city;
  ## :$userid:$branchid  ORDERID

}


=head1 ADMINISTRIVIA

=over

=item B<new( $context, $country_code, $state_code, $city_code )>

=item B<new( $context, $row_city )>

Accept a country code and a city code (or a DBIx::Class::Row object)
and create a fresh Class::City object from it. A context must be
provided.

Return the Class::City object, or undef if the City couldn't be
found.

=cut

# Constructor
sub new
{
  my $class		= shift;
  my $dbic		= shift;

  my $arg_countrycode	= shift;
  my $arg_statecode	= shift;
  my $arg_citycode	= shift;

  my ($r_hash_city,$already_existing,$me_err);
  my $m = "C/City->new";

  my $row;
  print "$m City IN: $arg_countrycode \n";

  try  {

    if (ref($arg_countrycode))
    {
      print "$m Row: $arg_countrycode \n";

      $arg_citycode	= $arg_countrycode->citycode;
      $arg_statecode	= $arg_countrycode->get_column('city_state');
      $arg_countrycode	= $arg_countrycode->get_column('city_country');
    }

    {
      ##TO Avoid UnXss messus with Row
      $arg_countrycode	= unxss($arg_countrycode);
      $arg_statecode	= unxss($arg_statecode);
      $arg_citycode	= unxss($arg_citycode);
    }


    $r_hash_city =
      "$c_prefix_key_city:$arg_citycode:$arg_statecode:$arg_countrycode";
    print "$m KEY: $r_hash_city \n";
    $already_existing =
      $o_redis->hexists($r_hash_city,'citycode');

    if (!$already_existing)
    {
      $row = get_dbrow($dbic,$arg_countrycode,$arg_statecode,$arg_citycode);
      #print "$m Row:$row \n";

      if (defined($row))
      {
	red_set_city($row);
	$already_existing = $o_redis->hexists($r_hash_city,'citycode');
	#print "$m Exist: $already_existing \n";

      }
    }

    ##Still Doesn't Exist
    if (!$already_existing)
    {
      ##Nothing If Row is also not available
      return undef;
    }

  }
    catch ($me_err)
      {
	print "$m $me_err \n";
      };



  my $self = bless( {}, $class );
  $self->{data}		= $r_hash_city;
  $self->{redis}	= $o_redis;
  $self->{db_object}	= $dbic;
  return ($self);


}

=head2 red_set_city($row_city)

Arguments: ($row_city)

For Edit:

=cut

sub red_set_city
{
  my $row_city = shift;

  my $f = "C/City::red_set_city";

  my ($f_citycode,$f_cityname,$f_city_state,$f_city_country,
      $f_state_name,$f_country_name);

  {
    $f_citycode	= 'citycode';
    $f_cityname	= 'cityname';
    $f_city_state	= 'city_state';
    $f_country_name	= 'country_name';
    $f_state_name	= 'state_name';
    $f_city_country	= 'city_country';
  }

  my ($v_citycode,$v_cityname,$v_city_state,$v_city_country,
      $v_country_name,$v_state_name);

  {
    $v_citycode	= trim($row_city->get_column($f_citycode));
    $v_cityname	= trim($row_city->get_column($f_cityname));
    $v_city_state	= trim($row_city->get_column($f_city_state));
    $v_city_country	= trim($row_city->get_column($f_city_country));

    $v_state_name   = trim($row_city->state->statename);
    $v_country_name =
      trim($row_city->state->state_country->countryname);

  }
  #print "$f $c_prefix_key_appuser \n";

  if($v_citycode && $v_city_state && $v_city_country)
  {
    my $key =
      "$c_prefix_key_city:$v_citycode:$v_city_state:$v_city_country";

    $o_redis->hset($key,$f_citycode,$v_citycode) ;
    $o_redis->hset($key,$f_cityname,$v_cityname)		if($v_cityname);
    $o_redis->hset($key,$f_city_state,$v_city_state)	if($v_city_state);
    $o_redis->hset($key,$f_city_country,$v_city_country)	if($v_city_country);

    $o_redis->hset($key,$f_country_name,$v_country_name)	if($v_country_name);
    $o_redis->hset($key,$f_state_name,$v_state_name)	if($v_state_name);

    $o_redis->expire($key,$c_expire_inan_hour);
  }
}


=head2 get_dbrow

Function Class::City::get_dbrow

Returns: the DBIx::Class::Row object for this DB Product
Get the database object.

Table City Primary Key: city_country(3),city_state(3),citycode(20)

Tries to find based on codes of country,state,city, if not found then
lowercase search for citycode.

=cut

sub get_dbrow
{
  my $dbic		= shift;
  my $arg_countrycode	= shift;
  my $arg_statecode	= shift;
  my $arg_citycode	= shift;

  my $fn = "C/City:get_dbrow";

  my $rs_city = $dbic->resultset("City");
  my $row;
  {
    $row	= $rs_city->find
      (
       {
	  city_country	=> $arg_countrycode, 
	  city_state	=> $arg_statecode,
	  citycode	=> $arg_citycode,
       }
      );
    print "$fn Found: $row \n";

    ##IF not Found
    if (!$row)
    {
      print "$fn Now Find Lower:$arg_citycode \n";
      my $lc_citycode = lc($arg_citycode);
      $rs_city = $rs_city->search
	(
	 {
	  city_country	=> $arg_countrycode,
	  city_state	=> $arg_statecode,
	  'lower(me.citycode)'	=> { 'LIKE' => $lc_citycode},
	 }
	);

      $row = $rs_city->first if(defined($rs_city));
      print "$fn Found: $row \n";
    }

  }


  #print "$fn $dbic Row:$row \n";
  return ( $row );

}

=head2 citycode

Returns: Citycode

=cut

sub citycode
{
  my $self  = shift;

  my $value;
  my $field = 'citycode';
  my $o_redis = $self->{redis};
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 city_code

Alias to $o_city->citycode

=cut

sub city_code
{
  my $self = shift;

  my $value = $self->citycode;

  return $value;

}


=head2 city_country

Returns: City_country

=cut

sub city_country
{
  my $self  = shift;

  my $value;
  my $field = 'city_country';
  my $o_redis = $self->{redis};
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 country_code

Alias to $o_city->city_country

=cut

sub country_code
{
  my $self = shift;

  my $value = $self->city_country;

  return $value;

}

=head2 city_state

Returns: City_state

=cut

sub city_state
{
  my $self  = shift;

  my $value;
  my $field = 'city_state';
  my $o_redis = $self->{redis};
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 state_code

Alias to $o_city->state_code


=cut

sub state_code
{
  my $self = shift;

  my $value = $self->city_state;

  return $value;

}


=head2 cityname

Returns: Cityname

=cut

sub cityname
{
  my $self  = shift;

  my $value;
  my $field = 'cityname';
  my $o_redis = $self->{redis};
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 city_name

Returns: Cityname

=cut

sub city_name
{
  my $self  = shift;

  my $value;
  $value = $self->cityname;
  return $value;

}


=head2 name

Returns: Cityname

=cut

sub name
{
  my $self  = shift;

  return $self->cityname;

}



=head1 COUNTRY/STATE NAMES

Not RECOMMENDED: As latest change in Country/State Names are available
after a day only.

=head2 state_name

Returns: State_name

=cut

sub state_name
{
  my $self  = shift;

  my $value;
  my $field = 'state_name';
  my $o_redis = $self->{redis};
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 country_name

Returns: Countr_name

=cut

sub country_name
{
  my $self  = shift;

  my $value;
  my $field = 'country_name';
  my $o_redis = $self->{redis};
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head1 Write Ops

Create and Update City Record

=head2 create($dbic,{name,statecode,countrycode,userid,citycodename,userid},Class::Country)

Returns: ($row_city,$o_city,$errors)

=cut

sub create
{
  my $dbic	= shift;
  my $in_vals	= shift;
  my $o_country = shift;

  my $fn = "C/city/create";
  my ($row_city,$o_city,$errors,$o_state);

  my ($citycode,$name,$city_state,$city_country,$userid);
  {
    $citycode		= $in_vals->{citycode}	|| $in_vals->{city};
    $name		= $in_vals->{name}	|| $in_vals->{cityname};
    $city_state		= $in_vals->{statecode} || $in_vals->{state};;
    $city_country	= $in_vals->{countrycode}||$in_vals->{country}
      ||$in_vals->{country_code};
    $userid		= $in_vals->{userid};
  }
  ##

  ##--  $citycode has 20 chars
  if ($citycode)
  {
    $citycode = substr($citycode,0,19);
  }
  else
  {
    $citycode = substr($name,0,19);
  }

  ##--Replace First Char as Capital, And other as Smaller case
#  {
#  }

  ##-- Object city,state,Country
  {
    $o_country	= Class::Country->new($dbic,$city_country)
      if(!$o_country);

    $o_state	= Class::State->new($dbic,$city_country,$city_state);

    $o_city	= Class::City->new
      ($dbic,$city_country,$city_state,$citycode);
  }

  my $in_h;
  $in_h->{userid}	= $userid;
  $in_h->{citycode}	= $citycode;
  $in_h->{city_state}	= $city_state;
  $in_h->{city_country} = $city_country;
  $in_h->{cityname}	= $name;

  ##-- Verified
  $in_h->{verified}	= 'f';

  my $t_city = $dbic->resultset('City');
  print "$fn $citycode,$name,$city_state,$city_country,$o_city \n";

  if ($userid && $name && !$o_city && $o_state)
  {
    print "$fn State Exists \n";
    $row_city = $t_city->create($in_h);
    $o_city	= Class::City->new($dbic,$city_country,$city_state,$citycode)
      if(defined( $row_city ));
  }
  else
  {
    print "$fn Missing Stuff \n";
    print "$fn $citycode,$name,$city_state,$city_country,$userid,$o_state \n";
  }

  ##--
  if (!$row_city)
  {
    print "$fn City: Not Created.\n";
  }


  return ($row_city,$o_city,$errors);

}


=head2 create_state_city

=cut

sub create_state_city
{
  my $dbic	= shift;
  my $in_vals	= shift;

  my ($o_state,$row_state,$s_errors);
  my ($o_city,$row_city,$c_errors) ;

  my $o_country;
  my $code_country	= $in_vals->{countrycode}||$in_vals->{country}
    ||$in_vals->{country_code};

  $o_country	= Class::Country->new($dbic,$code_country)
    if(!$o_country);

  if ($o_country)
  {
    $dbic->txn_do
      (sub
       {

	 ($row_state,$o_state,$s_errors) =
	   Class::State::create($dbic,$in_vals,$o_country);

	 ($row_city,$o_city,$c_errors)   =
	   Class::City::create($dbic,$in_vals,$o_country)
	   if ($o_state);

       });

  }

  return ($row_city,$o_city,$c_errors);

}

=back


=end


=back

=cut

1;
