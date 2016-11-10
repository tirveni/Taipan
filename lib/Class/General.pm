#!/usr/bin/perl -w
#
# Class/General
#
# Utility methods for DB abstraction classes.
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


=head2 page_details

Private method to get page contents

=cut

sub page_details 
{
  my $c         = shift;
  my $pageid    = shift;

  my $m = "R/page_details";

  my $dbic = $c->model('TDB')->schema;

  my $content;
  my $o_page = Class::Pagestatic->new( $dbic, $pageid );

  if ($o_page)
  {
    $content     = $o_page->content_lang($c);

    #$c->log->debug("$m :: OBJ content: $content");  
    $c->stash->{home}->{content} = $content;

#   my $attribs     = $o_page->tags($c);
#
#    if ($attribs)
#    {
#      my $meta_desc   = $attribs->{'meta-desc-staticpage'};
#      my $list_ofmeta = $attribs->{'meta-staticpage'};

#      $c->log->debug("$m :: meta_desc:$meta_desc ");  
#      $c->log->debug("$m :: list Meta: @$list_ofmeta");  

#      $c->stash->{meta}->{desc}		= $meta_desc;

#      $c->stash->{meta}->{listofmeta}   = $list_ofmeta;
#      ##This is Reference to Array.

#    }

  }

}


=back

=head2 paginationx ($c ,$search_attribs , $rs_table)

Handles  Pagination.With Multiple Search Parameters.

If hashindisplay is given then create display string from that else
used hashinsearch.

=cut

sub paginationx 
{
  my $c        = shift;
  my $attribs  = shift;
  my $rs_table = shift;

  my $fn = "G/paginationx:";

  my $desired_page   = $attribs->{desiredpage};
  my $startpage      = $attribs->{startpage} ;
  my $listname       = $attribs->{listname};
  my $namefn         = $attribs->{namefn};
  my $nameclass      = $attribs->{nameclass};
  my $input_search   = $attribs->{inputsearch};
  my $order          = $attribs->{order};
  my $in_rowsperpage = $attribs->{rowsperpage};

  $c->log->debug("$fn START Fx A, SP:$startpage, DP:$desired_page");

  #This is the Difference, Hash of Search Keys And Values
  my $in_search_h    = $attribs->{hashinsearch};
  my $in_display_h   = $attribs->{hashindisplay};

  #Search String 
  my $search_string  = undef;

  #Display String
  my $display_string = undef;

#Do the Search String / Display String
#1. Search String is always there
  if ($in_search_h)
  {
    my $s_count;
    $c->log->debug("$fn Create Search and Display String");
    while ( ( my $key, my $value ) = each(%$in_search_h) )
    {
      $c->log->debug("$fn SEARCH HASH $key : $value");
      if ( $key && $value )
      {
        $s_count++;
        my $str = "$key=$value";
        if ( $s_count != 1 )
        {
          $search_string   = "$search_string/" . $str;
          $display_string  = "$display_string, " . $str;
        }
        else
        {
          $search_string  = $str;
          $display_string = $str;
        }
      }
    }
    $c->log->debug("$fn \$search_string  : $search_string");
  }
#2. Display String is there
  if ($in_display_h)
  {
    my @key_vals;
    $c->log->debug("$fn :Create Display String as required");
    $display_string = undef;

    while ( ( my $key, my $value ) = each(%$in_display_h) )
    {
      $c->log->debug("G/paginationx :DISPLAY HASH $key : $value");
      if ( $key && $value )
      {
        my $str = "$key: $value";
        push(@key_vals,$str);
      }
    }
    $display_string = commify_series(@key_vals);
    $c->log->debug("$fn \$display_string : $display_string");
  }

  $c->log->debug("$fn START Fx B, SP:$startpage, DP:$desired_page");
  $startpage = 1 unless defined($startpage);
  if ( defined($desired_page) )
  {
    $startpage--
      if $desired_page eq 'previous';
    $startpage++
      if $desired_page eq 'next';
    $startpage = 1
      if $startpage < 1;
  }

  $c->log->debug("$fn START Fx C, SP:$startpage, DP:$desired_page");


  my $rows_per_page;
  if ( !$in_rowsperpage )
  {
    $rows_per_page = 2;
    $rows_per_page = Taipan->config->{display}->{generic}->{lines_per_page}
      if Taipan->config->{display}->{generic}->{lines_per_page};
  }
  else
  {
    $rows_per_page = $in_rowsperpage;
  }
 $c->log->debug ("$fn RS input :  ".
                  " Rows : $rows_per_page"
                 );

  my $rs_table_search ;

#Search : only if something has been found
  if ($rs_table)
  {
    $rs_table_search =  $rs_table->search
      (
       {},
       {
        order_by => $order,
        rows     => $rows_per_page
       }
      );
  }

  my $allitems = $rs_table_search->search(@$input_search);
  my $max_count;

  my $items    = $allitems->page($startpage);
  my $itempage = $items->pager();

  if ( $startpage > $itempage->last_page() )
  {
    $startpage = $itempage->last_page();
    $items     = $allitems->page($startpage);
    $itempage  = $items->pager();
  }
  $max_count = $itempage->total_entries;

  my $itempage_entries_per_page = $itempage->entries_per_page();
  my $itempage_page = $itempage->current_page();
  my $itempage_start = $itempage_entries_per_page * ( $itempage_page - 1 ) + 1;
  my $itempage_end = $itempage_start + $itempage->entries_on_this_page() - 1;
  my $itempage_total = $max_count;

  $c->log->debug("$fn \$itempage_entries_per_page: " .
                 " $itempage_entries_per_page" );
  $c->log->debug("$fn \$itempage_page:  $itempage_page");
  $c->log->debug("$fn \$itempage_start  $itempage_start");
  $c->log->debug("$fn \$itempage_end:   $itempage_end");
  $c->log->debug("$fn \$itempage_total: $itempage_total");
  $c->log->debug("$fn \$search_string:  $search_string");
  $c->stash->{listpage} =
    {
     start         => $itempage_start,
     end           => $itempage_end,
     total         => $itempage_total,
     page          => $itempage_page,
     listname      => $listname,
     namefn        => $namefn,
     nameclass     => $nameclass,
     searchstring  => $search_string,
     displaystring => $display_string,
    };

  return $items;

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
