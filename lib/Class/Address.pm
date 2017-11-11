#!/usr/bin/perl -w
#
# Class/Address.pm
#

package Class::Address;

use Moose;
use namespace::autoclean;

use Class::Utils
  qw(selected_language unxss unxss_an valid_email
     chomp_date valid_date get_array_from_argument trim );


=pod
=head1 NAME

Class::Address - Utilities for handling address-related data

=head1 SYNOPSIS

    use Class::Address;
    $oa = Class::Address->new( $dbic, $address );
    $row = $oa->dbrecord();

=head1 INHERITS

Class::Address inherits from Class::Country, Class::State,
Class::City, Class::ServiceArea, Class::Locality

=cut
#
# Parent classes.
use Class::Country;
use Class::State;
use Class::City;
use Class::Utils;


=head1 ADMINISTRIVIA

=over

=item B<new( $dbic, $address )>

Accept a address (either as a Address ID or as a DBIx::Class::Row
object and create a fresh Class::Address object from it. A context
must be provided.

Return the Class::Address object, or undef if the Address couldn't be
found.

=cut

# Constructor
sub new
{
  my $class		= shift;
  my $dbic		= shift;
  my $arg_addressid	= shift;

  my $m = "C::Address->new";

  my $row    = $arg_addressid;

  unless ( ref($arg_addressid) )
  {
    $arg_addressid = unxss($arg_addressid);
    if ($arg_addressid)
    {
      my $rs_address = $dbic->resultset('Address');
      $row	     = $rs_address->find($arg_addressid);
    }
  }

  return (undef)
    unless $row;

  my $self = bless( {}, $class );
  $self->{address_dbrecord}		= $row;

  return $self;

}

=item B<dbrecord()>

Return the DBIx::Class::Row object for this address.

=cut
# Get the database object
sub dbrecord
{
  my
    $self = shift;
  return( $self->{address_dbrecord} );
}

sub address_dbrecord
{
  my
    $self = shift;
  return( $self->{address_dbrecord} );
}


=item B<keys()>

For internal use only.  Return an array of the names of the key fields
for this table in the database.

=cut
sub keys
{
  return ( ('addressid') );
}


=back

=head1 ACCESSORS

=over


=item B<addressid>

=item B<statecode>

=item B<citycode>

=item B<areacode>

=item B<localitycode>

=cut
# Get/set country
sub countrycode
{
  my
    $self = shift;
  my
    $country = shift;
  $self->address_dbrecord->set_column('address_country', $country)
    if $country;
  my $value =  trim($self->address_dbrecord->get_column('address_country'));
  return($value );

}
sub statecode
{
  my
    $self = shift;
  my
    $state = shift;
  $self->address_dbrecord->set_column('address_state', $state)
    if $state;
  my $value = trim( $self->address_dbrecord->get_column('address_state'));
  return ($value );

}
sub citycode
{
  my
    $self = shift;
  my
    $city = shift;
  $self->address_dbrecord->set_column('address_city', $city)
    if $city;

  my $value = trim($self->address_dbrecord->get_column('address_city'));

  return ($value );
}

sub city_str
{
  my $self = shift;

  my $city = $self->citycode;
  my $state = $self->statecode;
  my $country = $self->countrycode;

  my $value = "$city, $state, $country";

  return $value;

}

sub addressid
{
  my
    $self = shift;
  return( $self->address_dbrecord->get_column('addressid'));
}


sub streetaddress1
{
  my
    $self = shift;

  my $value = trim($self->address_dbrecord->get_column('streetaddress1'));
  return ($value );
}


sub streetaddress2
{
  my
    $self = shift;
  my $value = trim($self->address_dbrecord->get_column('streetaddress2'));
  return ($value );
}

sub streetaddress3
{
  my
    $self = shift;

  my $value = trim($self->address_dbrecord->get_column('streetaddress3'));
  return ($value );
}


sub pincode
{
  my
    $self = shift;

  my $value = trim($self->address_dbrecord->get_column('pincode'));

  return ($value );

}

sub directions
{
  my
    $self = shift;

  my $value = trim($self->address_dbrecord->get_column('directions'));

  return ($value );

}

=back

=head1 OPERATIONAL METHODS

=over

=item B<create( $context, \%attribs )>

Create a new record in the address table.  Automatically sets the
AddressVerified field to false and the UseCount to 0.

The %attribs are used to fill out the record.  You need to pass at
least one attribute to keep DBIx::Class happy.

Returns the Class::Address object for the new record.

=cut

sub create
{
  my $dbic = shift;
  my
    $attribs = shift;
  # create a new address record.
  my $row_address = $dbic->resultset('Address')->create($attribs);
  my $o_address = Class::Address->new($dbic, $row_address);
  $row_address->addressverified('N');
  $o_address->address_dbrecord->update;
  return( $o_address );
}


=head2 get_cities  ( $dbic [,$o_address])

This Fn returns the Array of Hash of All the Cities.

=cut

sub get_cities 
{
  my $dbic       = shift;
  my $o_address = shift;

  my $f = "A/get_cities";

  my ( $countryadd, $stateadd, $cityadd, $address_co_st_ci );

  my $cities_rs ;
  my @order_by = qw(city_country city_state citycode);
  $cities_rs = $dbic->resultset('City')->search
      ( undef, {order_by => \@order_by} );

  my ($branch,$branch_code);

  if ($o_address)
  {
    $countryadd  = $o_address->countrycode;
    $stateadd    = $o_address->statecode;
    $cityadd     = $o_address->citycode;
    $address_co_st_ci  = $countryadd . "-" . $stateadd . "-" . $cityadd;
    print "$f Selected: /$address_co_st_ci/ \n";
  }

  my @list;
  @list = get_cities_ci_st_co
    ($dbic,$cityadd,$stateadd,$countryadd);
  return @list;

}

=head2 get_cities_ci_st_co  ( $dbic [,$city,$state,$country])

This Fn returns the Array of Hash of All the Cities.

=cut

sub get_cities_ci_st_co
{
  my $dbic		= shift;
  my $cityadd		= shift;
  my $stateadd		= shift;
  my $countryadd	= shift;

  my $f = "A/get_cities_ci_st_co";

  my $cities_rs ;
  my @order_by = qw(city_country city_state citycode);
  $cities_rs = $dbic->resultset('City')->search
      ( undef, {order_by => \@order_by} );

  my ($branch,$branch_code,$address_co_st_ci);
  if ($cityadd && $stateadd && $countryadd)
  {
    $address_co_st_ci  = $countryadd . "-" . $stateadd . "-" . $cityadd;
    #print "$f Selected: /$address_co_st_ci/ \n";
  }


  my @list;


  while ( my $city = $cities_rs->next() )
  {
    my $cityselected;
    my $citycode  = trim($city->citycode);
    my $cityname  = $city->cityname;
    my $citystate = $city->city_state;

    my ($row_country,$row_state);
    $row_state = $city->state;
    $row_country = $row_state->state_country;

    my ($countryname,$countrycode,$statename,$statecode);
    $countryname	= $row_country->countryname;
    $statename		= $row_state->statename;
    #
    $countrycode	= trim($row_country->countrycode);
    $statecode		= trim($row_state->statecode);
    my $co_st_ci = "$countrycode"."-"."$statecode"."-"."$citycode";
    #print "$f /$co_st_ci/ \n";

    if ( $address_co_st_ci  && ( $address_co_st_ci eq $co_st_ci ) )
    {
      $cityselected = "SELECTED='SELECTED'";
      print "$f SELECTED $co_st_ci \n";
    }


    push(
	 @list,
	 {
	  'citycode'	=> $citycode,
	  'cityname'	=> $cityname,
	  'citystate'	=> $citystate,
	  'statename'	=> $statename,
	  'countryname' => $countryname,
	  'countrystatecity' => $co_st_ci,
	  'selected'	=> $cityselected,
	 },
	);

  }				#while

  return @list;

}

=head1 Address Text

With comma Formatting.

=cut

=head2 text_hash  ( $dbic)

Full Text: With Cityname,StateNAme,Country

=cut

sub text_hash
{
  my $self	= shift;
  my $dbic       = shift;

  my $m = "A/fulltext";

  my ( $country, $state, $city,$city_name,$country_name,$state_name );

  my $city_state_country;
  if ($self)
  {
    $country  = $self->countrycode;
    $state    = $self->statecode;
    $city     = $self->citycode;
    $city_state_country = "$city, $state, $country";
  }

  my $o_city;
  $o_city = Class::City->new($dbic,$country,$state,$city)
    if($country && $state && $city);

  if ($o_city)
  {
    $country_name	= $o_city->country_name;
    $state_name		= $o_city->state_name;
    $city_name		= $o_city->city_name;
  }

  if ($country_name && $state_name && $city_name)
  {
    $city_state_country = "$city_name, $state_name, $country_name";
  }

  my ($s1,$s2,$s3,$pincode);
  $s1 = $self->streetaddress1;
  $s2 = $self->streetaddress2;
  $s3 = $self->streetaddress3;
  $pincode = $self->pincode;


  my $h_ax;
  $h_ax->{city}		= $city_name;
  $h_ax->{state}	= $state_name;
  $h_ax->{country}	= $country_name;

  $h_ax->{streetaddress1} = $s1;
  $h_ax->{streetaddress2} = $s2;
  $h_ax->{streetaddress3} = $s3;

  $h_ax->{pincode}	= $pincode;
  $h_ax->{directions}	= $self->directions;

  return $h_ax;

}

=head2 full_text  ( $dbic)

Full Text: With Cityname,StateNAme,Country

=cut

sub full_text
{
  my $self	= shift;
  my $dbic       = shift;

  my $m = "A/fulltext";

  if (!$dbic)
  {
    my $row_address = $self->dbrecord;
    $dbic = $row_address->result_source->schema;
  }

  my ( $country, $state, $city,$city_name,$country_name,$state_name );

  my $city_state_country;
  if ($self)
  {
    $country  = $self->countrycode;
    $state    = $self->statecode;
    $city     = $self->citycode;
    $city_state_country = "$city, $state, $country";
  }

  my $o_city;
  $o_city = Class::City->new($dbic,$country,$state,$city)
    if($country && $state && $city);

  if ($o_city)
  {
    $country_name	= $o_city->country_name;
    $state_name		= $o_city->state_name;
    $city_name		= $o_city->city_name;
  }

  if ($country_name && $state_name && $city_name)
  {
    $city_state_country = "$city_name, $state_name, $country_name";
  }

  my ($s1,$s2,$s3,$pincode);
  $s1 = $self->streetaddress1;
  $s2 = $self->streetaddress2;
  $s3 = $self->streetaddress3;
  $pincode = $self->pincode;

  my $a_text;
  if ($s1)
  {
    $a_text = $s1;
  }
  if ($s2)
  {
    $a_text = "$a_text, $s2";
  }
  if ($s3)
  {
    $a_text = "$a_text, $s3";
  }

  if ($city_state_country)
  {
    $a_text = "$a_text, $city_state_country";
  }

  if ($pincode)
  {
    $a_text = "$a_text, $pincode";
  }

  print "$m $a_text ";
  return $a_text;

}


=head2 brief_text  ( $dbic)

Full Text: With CityCode,StateCode,CountryCode

=cut

sub brief_text
{
  my $self	= shift;
  my $dbic	= shift;

  my $m = "A/fulltext";

  my $full_text = $self->full_text($dbic);
  return $full_text;

#  my ( $country, $state, $city,$city_name,$country_name,$state_name );

#  my $city_state_country;
#  if ($self)
#  {
#    $country  = $self->countrycode;
#    $state    = $self->statecode;
#    $city     = $self->citycode;
#    $city_state_country = "$city, $state, $country";
#  }

#  my ($s1,$s2,$s3,$pincode);
#  $s1 = $self->streetaddress1;
#  $s2 = $self->streetaddress2;
#  $s3 = $self->streetaddress3;
#  $pincode = $self->pincode;

#  my $a_text;
#  if ($s1)
#  {
#    $a_text = $s1;
#  }
#  if ($s2)
#  {
#    $a_text = "$a_text, $s2";
#  }
#  if ($s3)
#  {
#    $a_text = "$a_text, $s3";
#  }

#  if ($city_state_country)
#  {
#    $a_text = "$a_text, $city_state_country";
#  }

#  if ($pincode)
#  {
#    $a_text = "$a_text, $pincode";
#  }

#  print "$m $a_text ";
#  return $a_text;

}




=back

=cut

1;
