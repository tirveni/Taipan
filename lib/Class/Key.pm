#!/usr/bin/perl -w
#
# Class/Key.pm

#
# created on 2016-02-05
# Tirveni Yadav
#
# Version 3.2
# Key Checking for Method Access is working.
#
# Version 3.1
# Class::Key->new, and its accessors created.
#
# Version 2.1
# Redis Cache for Checking Keys.
#
package Class::Key;

use Class::Utils
  qw(unxss unxss_an valid_email push_errors print_errors
     chomp_date valid_date get_array_from_argument trim user_login);

use Moose;
use namespace::autoclean;
#
#  The use namespace::autoclean bit is simply good code hygiene, as it
#  removes imported symbols from your class's namespace at the end of
#  your package's compile cycle, including Moose keywords. Once the
#  class has been built, these keywords are not needed.
#



our $VERSION = "1.1";

=head1 Key

=cut

use Digest::SHA qw/sha1_hex/;
use String::MkPasswd qw(mkpasswd);  # To generate Random Password.
use TryCatch;

##
use Class::Utils qw(unxss get_random_string);
use Class::Rock;
use Class::Logintry;

=pod

=head1 NAME

Class::Key - Utilities for handling Key/API/Tokens

Hybrid of Redis(Local) and DBIC

=head1 SYNOPSIS

    use Class::Key;
    $o_key = Class::Key->new($id,$key ,$dbic );
    $o_key = Class::Key->new($id,$key );

    $valid		= $o_key->valid;
    $valid_from		= $o_key->valid_from;
    $valid_till		= $o_key->valid_till;

ApiUserKey: id(key_guava),key(key_jamun).

=cut

my ($o_redis,$c_prefix_key_appuser,$c_key_expires,$c_prefix_appuserkey);
my ($c_err_invalid_apikey,$c_is_key_cache_permitted);
{
  $o_redis		= Class::Utils::get_redis;
  $c_key_expires	= $Class::Rock::seconds_inten || 60;

  $c_prefix_key_appuser =  $Class::Rock::red_prefix_hash_appuser;

  $c_prefix_appuserkey	= $Class::Rock::red_prefix_apikey;
}

=head1

Key: uses table ApiUserKey.

ApiUserKey: id(key_guava),key(key_jamun).

Type: Token/API.

A. API: is the proper key for using through an Mobile App, or
applications. If a New API key is generated then all the older ones
are discarded.

B. Token is for temporary access. Multiple Keys valid can exist at a
time.Unless disable all the keys explicitly.


=cut

=pod

=head2 new($key_guava,key_jamun [,$dbic])

This is Pure Redis Method. No DBIC here only optional.

=cut

sub new
{
  my $class             = shift;
  my $key_guava		= shift;
  my $key_jamun		= shift;
  my $dbic		= shift;

  ##--- Get the Data from Postgres Stuff.
  if (defined($dbic) && $key_guava && $key_jamun)
  {
    my $row_appuserkey = get_dbrow($dbic,$key_guava,$key_jamun);
    Class::Key::store_in_red($row_appuserkey)
	if(defined($row_appuserkey));
  }


  my $m			= "C/key->new";
  my $f_valid		= 'valid';
  my $rkey		= "$c_prefix_appuserkey:$key_guava:$key_jamun";
  my $already_existing	= $o_redis->hget($rkey,$f_valid);

  ##Still Doesn't Exist
  if (!$already_existing)
  {
    ##Nothing If Row is also not available
    return undef;
  }

  my $self = bless( {}, $class );
  $self->{data}         = $rkey;
  $self->{redis}        = $o_redis;
  return ($self);



}

=head2 get_dbrow($dbic,$key_guava,$key_jamun)

Returns: Row_AppUserKey

=cut

sub get_dbrow
{
  my $dbic	= shift;
  my $key_guava = shift;
  my $key_jamun	= shift;

  my $rs_appuserkey = $dbic->resultset('Appuserkey');
  my $row_appuserkey = $rs_appuserkey->find
    (
     {
      key_guava		=> $key_guava,
      key_jamun		=> $key_jamun,
     },
    );

  return $row_appuserkey;

}

=head1 ACCESSORS

=head2 key_guava

Returns: Key Guava

=cut

sub key_guava
{
  my $self  = shift;

  my $value;
  my $field = 'key_guava';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}


=head2 key_jamun

Returns: Key Guava

=cut

sub key_jamun
{
  my $self  = shift;

  my $value;
  my $field = 'key_jamun';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 id

Alias to Key_guava

=cut

sub id
{
  my $self = shift;

  my $value = $self->key_guava;
  return $value;

}

=head2 key

Alias to Key_jamun

=cut

sub key
{
  my $self = shift;

  my $value = $self->key_jamun;
  return $value;

}


=head2 userid

Returns: Userid

=cut

sub userid
{
  my $self  = shift;

  my $value;
  my $field = 'userid';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}


=head2 valid

Returns: Valid

=cut

sub valid
{
  my $self  = shift;

  my $value;
  my $field = 'valid';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 valid_from

Returns: Valid_from

=cut

sub valid_from
{
  my $self  = shift;

  my $value;
  my $field = 'valid_from';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}


=head2 valid_till

Returns: Valid_till

=cut

sub valid_till
{
  my $self  = shift;

  my $value;
  my $field = 'valid_till';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 ip

Returns: Ip

=cut

sub ip
{
  my $self  = shift;

  my $value;
  my $field = 'ip';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 type

Returns: Type

=cut

sub type
{
  my $self  = shift;

  my $value;
  my $field = 'type';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 method

Returns: Method

=cut

sub method
{
  my $self  = shift;

  my $value;
  my $field = 'method';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 method_type

Returns: Method_type

=cut

sub method_type
{
  my $self  = shift;

  my $value;
  my $field = 'method_type';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 expiry

Returns: Expiry

=cut

sub expiry
{
  my $self  = shift;

  my $value;
  my $field = 'expiry';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 valid_from_epoch

Returns: Valid_from_epoch

=cut

sub valid_from_epoch
{
  my $self  = shift;

  my $value;
  my $field = 'valid_from_epoch';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}


=head2 valid_till_epoch

Returns: Valid_till_epoch

=cut

sub valid_till_epoch
{
  my $self  = shift;

  my $value;
  my $field = 'valid_till_epoch';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}



=head1 OPERATIONS

=head2 set_auth_keys($dbic, $userid,$valid_till)

Once the User is logged in then Set a key

Returns: Row_appuserkey

Function

=cut

sub set_auth_keys
{
  my $dbic		= shift;
  my $userid		= shift;
  my $valid_till	= shift;
  my $in_type		= shift;

  my $f = "A/set_auth_keys";

  my ($guava,$jamun,$count_keys,$counter);
  ($guava,$jamun) = generate_keys();

  my $rs_appuserkey	= $dbic->resultset('Appuserkey');
  $count_keys	= $rs_appuserkey->search
    ({key_guava=>$guava,key_jamun=>$jamun})->count;
  $counter = 1;
  print "$f Count Keys($counter): $count_keys \n";

  while ($counter < 21 && $count_keys != 0  )
  {
    $rs_appuserkey = $rs_appuserkey->search
      (
       {
	key_guava	=> $guava,
	key_jamun	=> $jamun,
       }
      );
    $counter++;
    $count_keys = $rs_appuserkey->count;
    ($guava,$jamun) = generate_keys($dbic);
    print "$f Count Keys($counter): $count_keys $guava/$guava \n";
  }


##Put the Values in the Database(biscuit)
  my $o_dt		= Class::Utils::date_time_utc;
  my $o_dt_nextday	= $o_dt->add(days=>1);
  my($next_day,$today,$yesterday);
  {
    my $fmt  = $dbic->storage->datetime_parser;
    $next_day = $fmt->format_datetime($o_dt_nextday);
    $today = Class::Utils::today;
    $yesterday = Class::Utils::add_days($today,-1);
  }


  $valid_till = valid_date($valid_till);

  my $k_type;
  if ($in_type eq 'API' || $in_type eq 'TOKEN')
  {
    $k_type = $in_type;
  }
  else
  {
    $k_type = 'API';
  }


  my $h_auk;
  {
    $h_auk->{userid}	= $userid;
    $h_auk->{key_guava} = $guava;
    $h_auk->{key_jamun} = $jamun;
    $h_auk->{valid_till} = $valid_till || $next_day;
    $h_auk->{valid}	= 't';
    $h_auk->{type}	= $k_type;
  }

  my $row;
  try
  {
    $row = $rs_appuserkey->create($h_auk);
  };

  return $row;
}

=head2 set_token($dbic,$userid,$valid_till)

Once the User is logged in then Set a key

Returns: Row_appuserkey

Function

=cut

sub set_token
{
  my $dbic		= shift;
  my $userid		= shift;
  my $valid_till	= shift;

  my $in_type		= 'TOKEN';
  my $row_auk = Class::Key::set_auth_keys($dbic,$userid,$valid_till,$in_type);

  return $row_auk;

}


=head2 generate_keys

Returns: Keys(guava,jamun)

=cut

sub generate_keys
{

  my $count_chars = '21';

#Create the Auth_Key,
  my $jamun  = get_random_string;
  my $guava  = get_random_string;
  {
    $guava	= Digest::SHA::sha256_hex($guava);
    $jamun	= Digest::SHA::sha256_hex($jamun);

    $guava	= unxss($guava);
    $jamun	= unxss($jamun);

    $guava = substr($guava,0,$count_chars);
    $jamun = substr($jamun,0,$count_chars);
  }

  return ($guava,$jamun);

}

=head2 check_auth_keys($dbic,$i_guava,[{$i_jamun,ip,epoch,authtype,url}])

Returns: (userID,$errors) 

If UserID is found for the Input API-Keys, ELSE Null.

Used by C/General::Input_Keys

=cut

sub check_auth_keys
{
  my $dbic = shift;
  my $i_guava	= shift;
  my $h_in	= shift;

  my ($v_method,$userid,$list_errors);
  my $m = "A/check_auth_keys";

  my ($in_ip,$in_epoch,$in_authtype,$i_jamun,$in_xdate,$in_url);
  {
    $i_jamun	= $h_in->{key} ||$h_in->{key_jamun};
    $in_ip	= $h_in->{ip};
    $in_xdate	= $h_in->{date};
    $in_epoch	= $h_in->{in_epoch};##Nonce
    $in_authtype= $h_in->{authtype};##AuthType,HMAC,etc
    $in_url	= $h_in->{url};
  }


  my $in_date;
  {
    my $o_dt = Class::Utils::date_time_utc;
    my $fmt  = $dbic->storage->datetime_parser;
    $in_date = $fmt->format_datetime($o_dt);
  }

  ##-- 1.First Check Throuugh REDIS
  if ($c_is_key_cache_permitted && $i_guava && $i_jamun && $in_date)
  {
    ($v_method,$userid,$list_errors) =
      Class::Key::red_check_auth_keys($i_guava,$i_jamun,$in_date);
    print "$m M:$v_method, U:$userid  \n";

  }

  ##-- 2. Then Through DBIC
  if (!$userid)
  {
    print "$m $i_jamun ; $i_guava ; $in_date  \n";
    my $rs_appuserkey = $dbic->resultset('Appuserkey');
    $rs_appuserkey = $rs_appuserkey->search
      (
       {
	key_jamun	=> $i_jamun,
	key_guava	=> $i_guava,
	valid_from	=> { '<=',	$in_date },
	valid_till	=> { '>',	$in_date },
	valid		=> 't',
       },
      );

    my $row_appuserkey = $rs_appuserkey->next;
    print "$m Found $rs_appuserkey  \n";
    if (defined($row_appuserkey))
    {
      $userid = $row_appuserkey->get_column('userid');
      $v_method = $row_appuserkey->get_column('method');

      if ($c_is_key_cache_permitted)
      {
	Class::Key::store_in_red($row_appuserkey);
	print "$m Saved in Redis. Now Get Userid  \n";
      }
    }
    print "$m M:$v_method, U:$userid  \n";
  }

  ##-- 3. IF Keys is permitted for only Method, then check if method
  ## is the same method.
  print "$m Get Method: $v_method/$in_url  \n";

  if ($v_method && ($in_url ne $v_method))
  {
    $userid = undef;
  }

  ##-- 3. Log Failed Attempt if User Still not found
  if (!$userid)
  {
    try
    {
      my $o_ltry = Class::Logintry::key_invalid($dbic,$i_guava,$h_in);
    }
  }

  return ($userid,$list_errors);

}


=head2 disable_active_keys($dbic,$userid,$type)

Disable All the Keys which are valid_till today( or greater) for an
user 

Returns: RS AppUSerKey

=cut

sub disable_active_keys
{
  my $dbic	= shift;
  my $userid	= shift;
  my $in_type	= shift || 'API';

  my $today = Class::Utils::today;
  my ($values,$ar_errors);

  my $rs_appuserkey ;

  try  {

    $rs_appuserkey = $dbic->resultset('Appuserkey');
    $rs_appuserkey = $rs_appuserkey->search
      (
       {
	userid     => $userid,
	valid	   => 't',
	valid_till =>  {'>=', $today },
       }
      );

    if ($in_type)
    {
      $rs_appuserkey = $rs_appuserkey->search({type=>$in_type});
    }

    if (defined($rs_appuserkey))
    {
      ##($values,$ar_errors) = red_disable_auth_keys(  $rs_appuserkey);
      $rs_appuserkey->update({valid => 'f',});
    }

  };

  return $rs_appuserkey;
}


=head2 key_user($dbic,$userid)

Arguments: $dbic,$userid

Returns: Row_appuserkey: Active User Key

IF More than one key is present, then period with later valid_till

=cut

sub key_user
{
  my $dbic	= shift;
  my $userid = shift;

  my $fn = "C/Key::key_user";
  my $row_appuserkey;
  my $today = Class::Utils::today;
  my $in_type = 'API';

  try {

    my @order_by = qw(valid_from valid_till);
    my $rs_appuserkey = $dbic->resultset('Appuserkey');
    $rs_appuserkey = $rs_appuserkey->search
      (
       {
	userid		=> $userid,
	valid_till	=> { '>',	$today },
	valid		=> 't',
	type		=> $in_type,
       },
       {
	order_by => \@order_by,
       },
      );

    $row_appuserkey = $rs_appuserkey->next();
    print " $fn Row:$rs_appuserkey \n";
  }

    return $row_appuserkey;

}

=head1 REDIS Storage for Key

=head2 store_in_red($row_appuserkey)

Stores Row Appuser in the Redis Local Cache.

=cut

sub store_in_red
{
  my $row_appuserkey	=	shift;

  my $fn = "C/Key/store_in_red";
  my ($f_guava,$f_jamun,$f_userid,$f_valid_from_epoch,$f_valid_till_epoch,
      $f_valid,$f_valid_from,$f_valid_till,$f_ip,$f_method,$f_method_type);
  {
    $f_guava		= 'key_guava';
    $f_jamun		= 'key_jamun';
    $f_userid		= 'userid';
    $f_valid		= 'valid';
    $f_valid_from	= 'valid_from';
    $f_valid_till	= 'valid_till';
    $f_valid_from_epoch = 'valid_from_epoch';
    $f_valid_till_epoch = 'valid_till_epoch';
    $f_ip		= 'ip';
    $f_method		= 'method';
    $f_method_type	= 'method_type';

  }

  my ($v_guava,$v_jamun,$v_userid,$valid_from,$valid_till,
      $v_valid,$valid_from_epoch,$valid_till_epoch,$v_ip,
     $v_method,$v_method_type);
  if (defined($row_appuserkey))
  {
    $v_guava	= trim($row_appuserkey->key_guava);
    $v_jamun	= trim($row_appuserkey->key_jamun);

    $v_userid	= trim($row_appuserkey->get_column('userid'));

    $valid_from =  $row_appuserkey->valid_from;
    $valid_till =  $row_appuserkey->valid_till;
    $v_valid	=  trim($row_appuserkey->valid);

    $v_ip	=  trim($row_appuserkey->ip);
    $v_method		=  trim($row_appuserkey->method);
    $v_method_type	=  trim($row_appuserkey->method_type);

    print "$fn $v_userid, $valid_from/$valid_till, $v_valid \n";
    $valid_from_epoch = Class::Utils::utc_datetime_to_epoch($valid_from);
    $valid_till_epoch = Class::Utils::utc_datetime_to_epoch($valid_till);
  }

  my $rkey = "$c_prefix_appuserkey:$v_guava:$v_jamun";

  if ($v_userid && $v_valid && $valid_from && $valid_till)
  {

    Class::Utils::redis_save_hash_field($o_redis,$rkey,$f_guava,$v_guava);
    Class::Utils::redis_save_hash_field($o_redis,$rkey,$f_jamun,$v_jamun);

    Class::Utils::redis_save_hash_field($o_redis,$rkey,$f_userid,$v_userid);
    Class::Utils::redis_save_hash_field($o_redis,$rkey,$f_valid,$v_valid);

    Class::Utils::redis_save_hash_field($o_redis,$rkey,$f_method,$v_method);
    Class::Utils::redis_save_hash_field
	($o_redis,$rkey,$f_method_type,$v_method_type);

    Class::Utils::redis_save_hash_field
	($o_redis,$rkey,$f_valid_from,$valid_from);
    Class::Utils::redis_save_hash_field
	($o_redis,$rkey,$f_valid_till,$valid_till);
    Class::Utils::redis_save_hash_field
	($o_redis,$rkey,$f_valid_till_epoch,$valid_till_epoch);
    Class::Utils::redis_save_hash_field
	($o_redis,$rkey,$f_valid_from_epoch,$valid_from_epoch);

    Class::Utils::redis_save_hash_field
	($o_redis,$rkey,$f_ip,$v_ip);

    $o_redis->expire($rkey,$c_key_expires);
  }

}


=head2 red_check_auth_keys($key_guava,$key_jamun)

Checks Key in the Cache

Returns($method,$userid,$errors)

=cut

sub red_check_auth_keys
{
  my $key_guava	=	shift;
  my $key_jamun =	shift;

  my $in_date	=	Class::Utils::utc_epoch();

  my ($ar_errors);
  my $fn = "C/Key/red_check_auth_keys";

  my ($f_guava,$f_jamun,$f_userid,$f_valid_from_epoch,$f_valid_till_epoch,
      $f_valid,$f_valid_from,$f_valid_till,$f_ip,$f_method,$f_method_type);
  {
    $f_guava		= 'key_guava';
    $f_jamun		= 'key_jamun';
    $f_userid		= 'userid';
    $f_valid		= 'valid';
    $f_valid_from	= 'valid_from';
    $f_valid_till	= 'valid_till';
    $f_ip		= 'ip';
    $f_valid_from_epoch = 'valid_from_epoch';
    $f_valid_till_epoch = 'valid_till_epoch';
    $f_method		= 'method';
    $f_method_type	= 'method_type';
  }


  my $rkey = "$c_prefix_appuserkey:$key_guava:$key_jamun";
  my $exists_rkey = $o_redis->hget($rkey,$f_valid);

  my ($userid,$v_method) ;
  if ($exists_rkey > 0 || $exists_rkey eq 't' )
  {
    my $from	= $o_redis->hget($rkey,$f_valid_from);
    my $till	= $o_redis->hget($rkey,$f_valid_till);
    $v_method	= $o_redis->hget($rkey,$f_method);

    my $from_epoch = $o_redis->hget($rkey,$f_valid_from_epoch);
    my $till_epoch = $o_redis->hget($rkey,$f_valid_till_epoch);

    $from_epoch = int($from_epoch);
    $till_epoch = int($till_epoch);

    print "$fn From:$from, In:$in_date, Till:$till, M:$v_method \n";

    if ( ($from_epoch && $till_epoch)
	 && ($from_epoch < $in_date) && ($in_date < $till_epoch))
    {
      $userid = $o_redis->hget($rkey,$f_userid);
      print "$fn User: Found: $userid \n";
    }

  }

  return ($v_method,$userid,$ar_errors);

}

=head2 red_disable_auth_keys($rs_appuserkeys)

Disables Keys : RS_appUserKey

=cut

sub red_disable_auth_keys
{
  my $rs_appuserkeys = shift;

  my $fn = "C/AppuserKey/red_disable_auth_keys";
  my $ar_errors;
  my $xvalues = 0;
  print "$fn For Expire :RS: $rs_appuserkeys \n";

  while (my $row = $rs_appuserkeys->next())
  {
    my $key_guava	=$row->key_guava;
    my $key_jamun	=$row->key_jamun;

    print "$fn For Expire: $key_guava/$key_jamun \n";

    my ($ar_errors);
    my $fn = "C/Key/red_disable_auth_keys";

    my ($f_valid);
    {
      $f_valid		= 'valid';
    }

    my $value;
    my $rkey = "$c_prefix_appuserkey:$key_guava:$key_jamun";
    my $exists_rkey = $o_redis->hget($rkey,$f_valid);
    print "$fn For Expire: $key_guava/$key_jamun/$exists_rkey \n";
    if ($exists_rkey)
    {
      $value = $o_redis->expire($rkey,1);
    }
    $xvalues += $value;
  }

  return ($xvalues,$ar_errors);

}


=back

=cut

1;
