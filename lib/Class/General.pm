#!/usr/bin/perl -w
#
# Class/General
#
# Utility methods for Maavalan DB abstraction classes.
#
#
use strict;

package Class::General;

use TryCatch;
#use Data::Dumper;

use JSON qw(decode_json);
use List::Util qw(min max sum);
use Class::Utils qw(makeparm selected_language unxss valid_date delta_days
		    commify_series trim);

#
# Required for testing only

use vars qw(@ISA @EXPORT_OK);
require Exporter;

@ISA        = qw/Exporter/;
@EXPORT_OK  = qw/
		 txn_do validate_job_access
		 config input_keys
		 paginationx get_countries
		 get_fields_from_argument get_preferencestype
		 date_begin_end
		/;

my ($o_redis);
{
  $o_redis = Class::Utils::get_redis;
}



=pod

=head1 DATABASE UTILITIES

=over

=item B<<< validate_job_access( $context [, $action] ) >>>

Validate access to the given $action, which is presumed to be a cron
task.  Validate access to any job action if $action is not specified.

Return true if access is permitted, under otherwise.

Note: Currently ignores $action.

=cut
# Validate access to cron job action
sub validate_job_access
{
  my
    $c = shift;
  my
    $action = shift;
  my
    $allowed = undef;
  #
  # Check for IP address
  my
    $allowed_ips = config(qw/internet cron allowed-ips/);
  my
    $client_ip = $c->req->address;
  foreach my $i( @$allowed_ips )
  {
    $allowed = 1
      if $client_ip eq $i;
  }
  #
  # That's it for now
  return( $allowed );
}


=item B<<< get_fields_from_class_name( $context, $class_name ) >>>

Return array of database fields for a table belonging to class
$class_name (Class::Foo).

=cut
# Get field names
sub get_fields_from_class_name
{
  my
    $c = shift;
  my
    $table = shift;
  $table =~ s/.*Class:://;
  $table =~ s/^(.)(.*)/\U$1\L$2/;
  my
    @columns = $c->model("TDB::$table")->result_source
      ->columns;
  return( @columns );
}


=back

=head1 CONFIGURATION

These methods let you access application configuration values easily.

=over

=item B<config($par1, $par2, ...)>

Get the configuration item corresponding to
config->{$par1}->{$par2}->...

Returns whatever the type of the configuration value is.

=cut
sub config
{
  my
    $val = Taipan->config;

  foreach my $p( @_ )
  {
    $val = $val->{$p};
  }
  return( $val );
}


=head1 input_keys($c,{ip,date,url})

Argument: $c for Headers

Returns: ({userid,branchid,errors,},is_key_given_but_failed)

Get the Input Keys/Tokens, check if The Keys are valid.

=cut

sub input_keys
{
  my $c		= shift;
  my $h_attempt	= shift;

  my $fn = "C/General/input_keys";
  my $h_val ;
  my $dbic = $c->model('TDB')->schema;


  #-- i_base:	is the ip/host of the Server
  #-- i_action: is the url without the Arguments
  #-- i_path:   is the url with arguments.
  #-- i_ip:	client IP
  my ($client_ip,$i_base,$i_action,$i_path);
  {
    $i_path	= $c->request->path;
    $i_action	= $c->action();
    $client_ip	= $c->request->address;
    $i_base	= $c->request->base; 
  }
  $c->log->debug("$fn Client IP:$client_ip, Base:$i_base, ".
		 "A:i_action, Path:$i_path \n");


  my ($i_jamun,$i_guava,$i_branchid,$i_epoch,$i_authtype,$i_xdate);
  {

    $i_branchid = trim($c->request->headers->header('branchid'));
    $i_epoch	= trim($c->request->headers->header('epoch'));
    $i_authtype = trim($c->request->headers->header('authtype'));
    $i_xdate = trim($c->request->headers->header('date'));

    my $authorization = $c->request->headers->header('Authorization');
    #$c->log->info("$fn  A: $authorization");
    my ($a_type,$a_value) = split(/ /,$authorization);
    #$c->log->info("$fn  $a_type/$a_value");


    $i_guava	=   $c->request->headers->header('key_guava')||
      $c->request->headers->header('id');

    $i_jamun	= $c->request->headers->header('key_jamun')||
      $c->request->headers->header('key');

    $i_guava	= trim($i_guava);
    $i_jamun	= trim($i_jamun);

  }

  $h_attempt->{branchid}	= $i_branchid	;
  $h_attempt->{epoch}		= $i_epoch	;
  $h_attempt->{authtype}	= $i_authtype	;
  $h_attempt->{key}		= $i_jamun	;
  $h_attempt->{ip}		= $client_ip;
  $h_attempt->{url}		= $i_action;

  my ($fruit_userid,$fruit_errors);
  my $is_key_given_but_failed = 0;
  my $h_val;


 CHECK_KEY_EXISTENCE:
  if($i_guava || $i_jamun)####IF Keys Exist
  {
    $is_key_given_but_failed = 1 ;

    ##Check Keys
    ($fruit_userid,$fruit_errors) = Class::Key::check_auth_keys
      ($dbic,$i_guava,$h_attempt);

    if ($fruit_userid)
    {
      $is_key_given_but_failed = 0;
      $h_val->{branchid}	= $i_branchid;
      $h_val->{userid}		= $fruit_userid;
      $h_val->{errors}		= $fruit_errors;
    }
  }

  return ($h_val,$is_key_given_but_failed);

}





=head1 JSON/HEADER

=head2 input_header($c,$key_string)

Input: $c, $Key_string

Returns: Value of the Key String for Input Header

=cut

sub input_header
{
  my $c			= shift;
  my $key_string	= shift;

  my $value = $c->request->headers->header($key_string);

  return $value;

}

=head2 sub get_json_array_of_hash($c)

Returns: Ref to Array of Hash

Use in Perl:

$decoded = Class::General::get_json_array_of_hash($c);

=head3 A. Client Jquery

Use in Jquery:

1.

var $xah = { 'product_code':$item_pc,'units':$item_unit};
$a_hitems.push($xah);

2. 
$.ajax(
  {
    url:		$url,
    data:		{'items':JSON.stringify($a_hitems)},
    traditional:	true,
    dataType:	        "json",
  },
);

=head3 B. Client Curl

Use through Curl Input of Items JSON:

1. cat a.json

{
  "items":
 [{"product_code":"abc","units":1},{"product_code":"def","units":"3"}]
}

2. 

curl -H 'Content-Type: application/json' $FQDN/restaurant/order/product/1685 -H 'key_guava:1111' -H 'key_jamun:2222' -X POST -d @/tmp/a.json

curl -H 'Content-Type: application/json' $FQDN/restaurant/order/product/5566 -H 'key_guava:1111' -H 'key_jamun:2222' -X POST -d '{"items":[{"product_code":"abc"},{"product_code":"def"}]}'

=cut

sub get_json_array_of_hash
{
  my $c		= shift;

  my $fn = "C/general/get_json_array_of_hash";
  my $aparams	= $c->request->params;

  my $decoded;

  try
  {
    my $a_hitems;
    my $in_data	= $c->req->data;
    $a_hitems	= $in_data->{items};
    if(ref($a_hitems) eq 'ARRAY')
    {
      $c->log->info("$fn JSON: ARRAY, CURL type ");
      $decoded = $a_hitems;
    }
    else
    {
      $c->log->info("$fn Else: Input APARAMS" );
      my $xitems	= $aparams->{items};
      $decoded		= decode_json($xitems);
      $c->log->info("$fn Adding Decoded: $decoded");

    }
    #print Dumper($decoded);
    $c->log->info("$fn Got the data");
  };

  return $decoded;

}

=head2 sub get_json_hash($c)

Returns: Ref to Hash

Use in Perl:

$decoded = Class::General::get_json_hash($c);

=head3 A. Client Jquery

Use in Jquery:

1.

var $h_items = { 'product_code':$item_pc,'units':$item_unit};

2. 
$.ajax(
 {
   url:		$url,
   data:		$h_items,
   traditional:	true,
   dataType:	"json",
 },
);

=head3 B. Client Curl

Use through Curl Input of Items JSON:

1. cat a.json

  {"product_code":"abc","units":1}

2. 

curl -H 'Content-Type: application/json' $FQDN/restaurant/order/product/1685 -H 'key_guava:1111' -H 'key_jamun:2222' -X POST -d @/tmp/a.json


=head3 C. Client Curl (-d)

curl -H 'Content-Type: application/json' $FQDN/restaurant/order/5653 -H 'key_guava:1111' -H 'key_jamun:2222' -X PUT -d '{"discount":"abc"}'


=cut

sub get_json_hash
{
  my $c		= shift;

  my $fn = "C/general/get_json_hash";
  my $aparams	= $c->request->params;

  my $decoded;

  try  {

    my $h_items;
    my $in_data	= $c->req->data;
    $h_items	= $in_data->{items};

    my $xitems	= $aparams->{items};
#    print "$fn params:$aparams, / data:$in_data \n";
#    print "$fn In Data(JSON):   \n";
#    print Dumper($in_data);
#    print "$fn In Aparams:   \n";
#    print Dumper($aparams);

    if (%$aparams)
    {
      $c->log->info("$fn IF Input APARAMS" );
      $decoded = $aparams;
    }
    elsif(ref($in_data) eq 'HASH')
    {
      ##Curl
      $c->log->info("$fn IF JSON Curl");
      $decoded = $in_data;
    }

    #print Dumper($decoded);
    $c->log->info("$fn Got the data");

  };

  return $decoded;

}


=head1 CACHE

using REDIS (String)

=over

=head2 set_cache

=cut

sub set_cache
{
  my $in_key	= shift;
  my $in_value	= shift;
  my $expires	= shift;

  my $o_redis = Class::Utils::get_redis;

  $o_redis->set($in_key,$in_value);
  $o_redis->expires($in_key,$expires);

  return ;
}

=head2 get_cache

=cut

sub get_cache
{
  my $in_key	= shift;

  my $o_redis = Class::Utils::get_redis;
  my $value	    = $o_redis->get($in_key);


  return $value;

}



=over

=back


=cut

1;
