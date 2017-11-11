package Taipan::Controller::G::Address;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

use TryCatch;

use Class::Country;
use Class::Utils qw(makeparm selected_language unxss unxss_an chomp_date
		    valid_date get_array_from_argument trim user_login);


my ($o_appuser,$c_userid,$in_data,$h_rest);

my ($c_pod_url);
{
  $c_pod_url            = Taipan->config->{pod_url};
}

=head1 NAME

Taipan::Controller::G::Address - User Address API

REST API for User

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 auto

permission handling

=cut

sub auto : Private
{
  my $self		= shift;
  my $c			= shift;

  my $f = "G/Address/auto";
  my $dbic = $c->model('TDB')->schema;

  $c->log->info("$f auto");
  {
    $c_userid = $c->stash->{hello}->{user};
    $c_userid = 'UNKN' if(!$c_userid);
  }

  $o_appuser = Class::Appuser->new($dbic,$c_userid)
    if($c_userid);

  my $in_data = $c->req->data;
  $c->log->info("$f $c_userid");
}


=head1 City

City Add

=cut

sub city :Path('/g/address/city') :Args(0)  : ActionClass('REST')
{
}

=head2 /g/address/city			POST

REST Verb POST

In Data:
{country_code,state_code,new_state_code,new_state_name,city_name,code}

1.Add only city (state is available): country_code,state_code,city_name

2.Add State and City: country_code,new_state_code,new_state_name,city_name

Success Returns: Hash {country_code,state_code,city_code,name}

=cut

sub city_POST
{
  my ( $self, $c ) = @_;

  my $m = "G/user/city_POST";
  $c->log->debug("$m Start ");

  my $dbic	= $c->model('TDB')->schema;
  my $o_redis	= Class::Utils::get_redis;
  my $in_data	=  Class::General::get_json_hash($c);

  my $c_action = "/g/user/city_add";

  my ($country_code,$state_code,$city_code,$city_name,
      $new_state_code,$new_state_name);
  {
    $country_code	= unxss($in_data->{country_code});
    $state_code		= unxss($in_data->{state_code});

    $new_state_code	= unxss($in_data->{new_state_code});
    $new_state_name	= unxss($in_data->{new_state_name});

    $city_name		= $in_data->{city_name} || $in_data->{name};

    my $code_cou_sta	= $in_data->{code};
    if ($code_cou_sta)
    {
      ($country_code,$state_code)  = split(/:/,$code_cou_sta);
      $country_code	= unxss($country_code);
      $state_code	= unxss($state_code);
    }
    $c->log->info("$m CC:$country_code,ST:$state_code,City:$city_name");
  }

  my $err_msg = "Error";
  my ($row_city,$o_city,$errors);
  if ($city_name && $country_code && $new_state_code && $new_state_name)
  {
      $c->log->info("$m City and State Add");
      my $h_cx;
      $h_cx = {
	       country		=> $country_code,

	       statecode	=> $new_state_code,
	       statename	=> $new_state_name,

	       cityname		=> $city_name,
	       userid		=> $c_userid,
	      };

      ($row_city,$o_city,$errors) =
      Class::City::create_state_city($dbic,$h_cx);
      $c->log->info("$m City:$row_city/$o_city");
      if ($errors)
      {
	$err_msg = pop(@$errors);
      }
  }
  elsif ($city_name && $country_code && $state_code)
  {
      my $h_cx;
      $h_cx = {
	       country	=> $country_code,
	       state	=> $state_code,
	       name	=> $city_name,
	       userid		=> $c_userid,
	      };

      ($row_city,$o_city,$errors) = Class::City::create($dbic,$h_cx);
      $c->log->info("$m City:$row_city/$o_city");
      if ($errors)
      {
	$err_msg = pop(@$errors);
      }
  }
  elsif (!$country_code)
  {
    $err_msg = "country_code is missing";
  }
  elsif (!$state_code)
  {
    $err_msg = "state_code is missing";
  }
  elsif (!$city_name)
  {
    $err_msg = "city_name is missing";
  }

  if ($row_city && $o_city)
  {
    $h_rest->{name}		= $o_city->city_name;
    $h_rest->{country_code}	= $o_city->country_code;
    $h_rest->{state_code}	= $o_city->state_code;
    $h_rest->{city_code}	= $o_city->city_code;
  }

  ##--
  if (defined($row_city))
  {
    $self->status_created( $c, entity => $h_rest,location=>'');
    return;
  }
  elsif ($o_city)
  {
    my $err_msg = "Existing City";
    $self->status_bad_request( $c, message=>$err_msg );
    return;
  }
  else
  {
    $c->log->info("$m $err_msg");
    $self->status_bad_request( $c, message=>$err_msg );
    return;
  }



}

=head1 States

=cut

sub states :Path('/g/address/states') :Args(1)  : ActionClass('REST')
{
}


=head2  g/address/states/:page	GET

 Output is json.

Input:{countrycode|country}

Country is optional: iCountry||country. IF country is given then
search is made for states only in the Country.

OutPut:    {countrycode,countryname,statename,statecode,name,code}

Example: /G/address?q=new delhi&country=IN

=cut

sub states_GET
{
  my ( $self, $c, $page_number ) = @_;

  my $dbic = $c->model('TDB')->schema;
  my $f = "G/Address/states_GET";
  $c->log->debug("$f Start GET");

  # Input Types
  my $pars	= makeparm(@_);
  my $aparams   = $c->request->params;
  my $q_search	= $aparams->{q};
  $c->log->debug("$f Search: $q_search");

  my $rows_per_page = 100;
  $page_number	 = int($page_number) || 1;

  my $in_country = $aparams->{countrycode}||$in_data->{country};
  $in_country    = unxss($in_country);

  my $table_state = $dbic->resultset('State');

  my @list;
  ##JsonLD
  my ($jld_context,$jld_type,$jld_url);
  {
    $jld_context = $c_pod_url;
    $jld_type    = 'City';
    $jld_url	 = "$c_pod_url/g/address/state/";
  }

  my ($o_country,$country_name,$country_code);
  if ($in_country)
  {
    $c->log->debug("$f Country: $in_country ");
    $o_country = Class::Country->new($dbic,$in_country);
  }

  my $rs_states ;
  if($o_country)
  {
    $rs_states = $table_state->search({state_country=>$in_country});
    $country_name = $o_country->countryname;
    $country_code = $o_country->countrycode;
  }


  if($q_search)
  {
    $rs_states = $table_state->search
      ({statename => {'ilike' => "%$q_search%",} }
      );
  }


  if (!defined($rs_states))
  {
    $self->status_not_found($c, message => 'State Not Found');
    return;
   }

  while ( my $row_state = $rs_states->next() )
  {

    my ($st_code,$st_name,$name);
    #$c->log->debug("$f City: $row_state");

    $st_name = trim($row_state->statename);
    $st_code = trim($row_state->statecode);

    $name = "$st_code, $country_code";
    if ($country_name && $st_name)
    {
      $name = "$st_name, $country_name";
    }

    my $code = "$country_code:$st_code";
    $c->log->info("$f Name:$name");

    push(@list,
	 {
	  countrycode	=> $country_code,
	  countryname	=> $country_name,
	  statename	=> $st_name,
	  statecode	=> $st_code,

	  name		=> $name,
	  code		=> $code,
	 },
	);
  }

  my $h_rest;
  #$h_rest->{'@context'} = $jld_context;
  #$h_rest->{'@type'}	= $jld_context;


  if (@list)
  {
    ##Both of the below are the same.
    $h_rest->{states} = \@list;
    $self->status_ok( $c, entity => $h_rest );
  }
  elsif ($o_country)
  {
    my $err_msg = "$q_search.. not found in $country_name";
    push(@list,{name=> $err_msg});
    $h_rest->{cities} = \@list;
    $self->status_ok( $c, entity => $h_rest );
  }
  else
  {
    $self->status_not_found($c, message => 'States Not Found');
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
