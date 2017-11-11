package Taipan::Controller::Asearch;
use Moose;
use namespace::autoclean;

#BEGIN { extends 'Catalyst::Controller'; }

BEGIN { extends 'Catalyst::Controller::REST'; }

## READ This
## https://metacpan.org/pod/Catalyst::Controller::REST


use Class::Utils qw(makeparm selected_language unxss chomp_date
                    get_array_from_argument trim);
use Class::General;

my ($c_pod_url);
{
  $c_pod_url            = Taipan->config->{pod_url};
}


=head1 NAME

Taipan::Controller::Asearch - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller:
For autocomplete option of cities,Timezone,Countries,Currrencies etc.


=head1 METHODS

=cut


=head2 City

=cut

sub index :Path(/city) :Args(0)  : ActionClass('REST')
{
#    my ( $self, $c ) = @_;
#    $c->response->body('Matched Taipan::Controller::City in City.');
}


=head3  asearch/city/:citycode	GET

list_GET method. Output is json.

OutPUT: Array of Hash    {cityname,citycode,state,country}

=cut

sub index_GET 
{
  my ( $self, $c, $city_code ) = @_;


  my $f = "City/index_GET";
  $c->log->debug("$f Start GET");  

  # Input Types
  my $pars         = makeparm(@_);
  my $aparams      = $c->request->params;
  my $body_pars;#		= $c->request->body_data;

#  my @db_keys = %$body_pars;
  $c->log->debug("$f aparams:$aparams");

##  my $p_method = $c->request->method;
  $city_code = unxss($city_code);

  my $rows_per_page = 1;

  my $rs_cities = $c->model('TDB::City')->search
    ({},{rows =>$rows_per_page}) ;

  if ($city_code)
  {
    $rs_cities = $rs_cities->search({citycode=>$city_code});
  }
  my @list;

  while ( my $rs_city = $rs_cities->next() )
  {

    my $city_state      = $rs_city->get_column('city_state');
    my $city_country    = $rs_city->get_column('city_country');
    my $cityname        = $rs_city->cityname;
    my $citycode        = $rs_city->citycode;

    $c->log->debug("$f CityCode: $citycode");

    my $link =
      "?in_country=$city_country&in_state=$city_state&citycode=$citycode";

    push(@list,
	 {
	  cityname  => $cityname,
	  citycode  => $citycode,
	  state     => $city_state,
	  country   => $city_country,
#	  infolink  => $link,
	 },
	);
  }

  $self->status_ok( $c, entity => \@list );

}


=head3  index_OPTIONS

list_GET method. Output is json.

=cut

sub index_OPTIONS
{
  my ( $self, $c ) = @_;


  my $f = "City/index_OPTIONS";
  $c->log->debug("$f Start ");  

  $c->response->status(200);
  $c->response->body("200 OK");


}


=head1 cities

=cut

sub cities :Path('/asearch/cities') :ChainedArgs(0)  : ActionClass('REST')
{
#    my ( $self, $c ) = @_;
#    $c->response->body('Matched Taipan::Controller::City in City.');
}


=head3  cities_GET

list_GET method. Output is json.

data.cities

Country is optional: iCountry||country. IF country is given then
search is made for cities only in the Country.

Example: /asearch/cities?q=new delhi&country=IN

OutPut: Array of Hash   {country,state,name,cityname,citycode,code}

=cut

sub cities_GET
{
  my ( $self, $c, $rows_per_page, $page_number ) = @_;

  my $dbic = $c->model('TDB')->schema;
  my $f = "asearch/cities_GET";
  $c->log->debug("$f Start GET");

  # Input Types
  my $pars         = makeparm(@_);
  my $aparams      = $c->request->params;
  my $q_search	   = $aparams->{q};
  $c->log->debug("$f Search: $q_search");

  $rows_per_page = int($rows_per_page) || 10;
  $page_number	 = int($page_number) || 1;

  my $in_country = $aparams->{icountry}||$aparams->{country};
  $in_country    = unxss($in_country);

  my $table_cities = $c->model('TDB::VCity')->search();

  my @list;
  ##JsonLD
  my ($jld_context,$jld_type,$jld_url);
  {
    $jld_context = $c_pod_url;
    $jld_type    = 'City';
    $jld_url	 = "$jld_context/asearch/cities/";
  }

  my ($o_country,$country_name);
  if ($in_country)
  {
    $c->log->debug("$f Country: $in_country ");
    $o_country = Class::Country->new($dbic,$in_country);
  }

  if($o_country)
  {
    $table_cities = $table_cities->search({city_country=>$in_country});
    $country_name = $o_country->countryname;
  }



  my $rs_cities ;
  $rs_cities = $table_cities->search
    ({cityname => {'ilike' => "%$q_search%",} }
    )
     if($q_search);

  if (!defined($rs_cities))
  {
    $self->status_not_found($c, message => 'Cities Not Found');
    return;
   }

  while ( my $row_vcity = $rs_cities->next() )
  {

    my ($co_code,$st_code,$city_code);
    my ($co_name,$st_name,$ci_name,$name);

    $co_code	= trim($row_vcity->city_country);
    $st_code	= trim($row_vcity->city_state);
    $city_code	= trim($row_vcity->citycode);
    $ci_name	= trim($row_vcity->cityname);
    $co_name	= trim($row_vcity->countryname);
    $st_name	= trim($row_vcity->statename);

    $name = "$ci_name, $st_code, $co_code";
    if ($co_name && $st_name && $ci_name)
    {
      $name = "$ci_name, $st_name, $co_name";
      $c->log->debug("$f City: $co_name,$st_name,$ci_name ");
    }

    my $code = "$co_code:$st_code:$city_code";
    $c->log->debug("$f Name:$name");

    my $link = "$jld_url"."$city_code";



    push(@list,
	 {
	  url		=> $link,
	  country	=> $co_code,
	  state		=> $st_code,
	  name		=> $name,
	  cityname	=> $ci_name,
	  citycode	=> $city_code,
	  code		=> $code,
	 },
	);
  }

  my $h_rest;
  $h_rest->{'@context'} = $jld_context;
  $h_rest->{'@type'}	= $jld_context;


  if (@list)
  {
    ##Both of the below are the same.
    #$c->stash->{rest} = \@list;
    $h_rest->{cities} = \@list;
    $self->status_ok( $c, entity => $h_rest );
  }
  elsif ($o_country)
  {
    my $msg = "$q_search.. not found in $country_name";
    push(@list,{name=> $msg});
    $h_rest->{cities} = \@list;
    $self->status_ok( $c, entity => $h_rest );
  }
  else
  {
    $self->status_not_found($c, message => 'Cities Not Found');
  }

}

=head1 timezones

=cut


sub timezones :Path('/asearch/timezones') :Args(0)  : ActionClass('REST')
{
#    my ( $self, $c ) = @_;
#    $c->response->body('Matched Taipan::Controller::City in City.');
}


=head3  /asearch/timezones	GET

list_GET method. Output is json.

Output: Array of Hash    {country,zoneid,zonename}

Input Search Parameters:: q/tz_city/tz_countrycode

q:			zone_name

tz_city:		city_code:state_code:country_code

tz_countrycode:		Country_Code

=cut

sub timezones_GET
{
  my ( $self, $c) = @_;

  my $dbic = $c->model('TDB')->schema;
  my $f = "asearch/timezones_GET";
  $c->log->debug("$f Start GET");

  # Input Types
  my $pars         = makeparm(@_);
  my $aparams      = $c->request->params;
  my $q_search	= $aparams->{q};
  #$c->log->debug("$f Search: $q_search");

  my $tz_city = $aparams->{tz_city};
  #$c->log->debug("$f Search : $tz_city");
  my $tz_countrycode = unxss($aparams->{tz_countrycode});
  #$c->log->debug("$f Search : $tz_countrycode");

  my ($rows_per_page,$page_number);
  $rows_per_page  = 100;
  $page_number	  = 1;

  my $table_timezones = $c->model('TDB::Zone')->search();


  my @list;
  ##JsonLD
  my ($jld_context,$jld_type,$jld_url);
  {
    $jld_context = $c_pod_url;
    $jld_type    = 'Timezone';
    $jld_url	 = "$jld_context/asearch/timezones/";
  }
  my $rs_timezones ;
  if($q_search)
  {
    $rs_timezones = $table_timezones->search
      ({zone_name => {'ilike' => "%$q_search%",} }
      );
  }

  if ($tz_countrycode)
  {
    $rs_timezones = $table_timezones->search
      ({countrycode => $tz_countrycode,}
      );
    #$c->log->debug("$f Country:$tz_countrycode");
  }
  elsif ($tz_city)
  {
    my ($country_code,$state_code,$city_code) = split(/:/,$tz_city);
    $country_code = unxss($country_code);
    $rs_timezones = $table_timezones->search
      ({countrycode => $country_code,}
      ) if($country_code);
    #$c->log->debug("$f Country:$country_code");

  }


  while ( my $row_z = $rs_timezones->next() )
  {
    my ($co_code);
    my ($zone_id,$zone_name);
    $zone_id	= $row_z->zone_id;
    $zone_name	= $row_z->zone_name;
    $co_code	= $row_z->get_column('countrycode');
    my $link = "$jld_url"."$zone_id";
    $c->log->debug("$f $zone_name,$zone_id");

    push(@list,
	 {
	  '@context'	=> $jld_context,
	  '@type'	=> $jld_type,
	  url		=> $link,
	  country	=> $co_code,
	  zoneid	=> $zone_id,
	  zonename	=> $zone_name,
	 },
	);

  }

  if (@list)
  {
    $self->status_ok( $c, entity => \@list );
  }
  else
  {
    $self->status_not_found($c, message => 'Timezones Not Found');
  }

}


=head1 currencies

=cut


sub currencies :Path('/asearch/currencies') :Args(1)  : ActionClass('REST')
{
#    my ( $self, $c ) = @_;
#    $c->response->body('Matched Taipan::Controller::City in City.');
}


=head3  /asearch/currencies/:currency_name	GET

list_GET method. Output is json.

Array of Hash    {currencycode,code,name,currencyname,symbol}

=cut

sub currencies_GET
{
  my ( $self, $c, $q_search ) = @_;

  my $dbic = $c->model('TDB')->schema;
  my $f = "asearch/currencies_GET";
  $c->log->debug("$f Start GET");

  # Input Types
  my $pars	= makeparm(@_);
  my $aparams	= $c->request->params;
  #my $q_search	= $aparams->{q};
  $c->log->debug("$f Search: $q_search");

  my ($rows_per_page,$page_number);
  $rows_per_page = 20;
  $page_number   = 1;

  my $table_currencies = $c->model('TDB::Currency')->search();


  my @list;
  ##JsonLD
  my ($jld_context,$jld_type,$jld_url);
  {
    $jld_context = $c_pod_url;
    $jld_type    = 'City';
    $jld_url	 = "$jld_context/currencies/";
  }
  my $rs_currencies ;
  $rs_currencies = $table_currencies->search
    ({currencyname => {'ilike' => "%$q_search%",} }
    )
     if($q_search);

  while ( my $row_z = $rs_currencies->next() )
  {
    my ($cu_code);
    my ($currency_name,$symbol);

    $cu_code	= $row_z->get_column('currencycode');
    $currency_name	= $row_z->currencyname;
    $symbol	= $row_z->symbol;

    my $link	= "$jld_url"."$cu_code";


    push(@list,
	 {
	  '@context'	=> $jld_context,
	  '@type'	=> $jld_type,
	  url		=> $link,
	  currencycode	=> $cu_code,
	  code		=> $cu_code,
	  name		=> $currency_name,
	  currencyname	=> $currency_name,
	  symbol	=> $symbol,
	 },
	);
  }

  if (@list)
  {
    $self->status_ok( $c, entity => \@list );
  }
  else
  {
    $self->status_not_found($c, message => 'Currencies Not Found');
  }

}





=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
