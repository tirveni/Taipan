#!/usr/bin/perl -w
#
# Copyright Tirveni Yadav, 2015-07-30.
# License: GPLv3
#


package Class::Logintry;

use Moose;
use namespace::autoclean;
use TryCatch;

use Class::Utils qw(unxss trim push_errors print_errors);

my ($o_redis,$c_expire_ina_day);
my ($c_err_invalid_apikey,$c_err_invalid_request);
{
  $o_redis = Class::Utils::get_redis;
  $c_expire_ina_day = $Class::Rock::seconds_day || 90000;

  $c_err_invalid_apikey		= "3060403";
  $c_err_invalid_request	= "3070403";

}



=pod

=head1 NAME

Class::Logintry - Utilities for handling LoginAttempts-related data

=head1 SYNOPSIS

    use Class::Logintry;
    $l_ltry	= Class::Logintry->new( $dbic, $LoginAttempts );
    $row	= $l_ltry->dbrecord;
    $o_ip	= $l_ltry->ip;

=head1 METHODS

=over

=item B<new( $context, $IP, [$date_time] )>

Accept a LoginAttempts (either as a IP or as a DBIx::Class::Row
object and create a fresh Class::Logintry object from it. A context
must be provided.

Return the Class::Logintry object, or undef if the IP couldn't be
found.

=cut

# Constructor
sub new
{
  my $class	= shift;
  my $dbic	= shift;
  my $arg_ip	= shift;
  my $date	= shift;

  my $m = "C/LA->new";

  my $row    = $arg_ip;
  my $h_page;
  $h_page->{order_by} = ['created_at DESC'] ;

  unless ( ref($arg_ip) )
  {
    $arg_ip = unxss($arg_ip);
    my $rs_latt	= $dbic->resultset('Logintry');

    if ($date && $arg_ip)
    {
      $row = $rs_latt->find($arg_ip,$date);
    }
    elsif ($arg_ip)
    {
      $rs_latt		= $rs_latt->search($arg_ip,$h_page);
      $row		= $rs_latt->first;
    }
  }

  return (undef)
    unless $row;

  my $self			= bless( {}, $class );
  $self->{loginattemps_dbrecord}	= $row;

  return $self;
}


=item B<dbrecord()>

Return the DBIx::Class::Row object for this LoginAttempts.

=cut
# Get the database object
sub dbrecord
{
  my
    $self = shift;
  return( $self->{loginattempts_dbrecord} );
}

=back

=head1 ACCESSORS

=over

=head2 ip

GET IP of the Login Attempts

=cut

sub ip
{
  my $self = shift;

  my $value;
  my $field = 'ip';

  $value = $self->dbrecord->get_column('ip_address');

  return $value;
}



=back

=head2 userid

GET userid of the Logintry

=cut

sub userid
{
  my $self = shift;

  my $value;
  my $field = 'userid';

  $value = $self->dbrecord->get_column('userid');

  return $value;
}

=head2 date

GET date of the Logintry

=cut

sub date
{
  my $self = shift;

  my $value;
  my $field = 'date';

  $value = $self->dbrecord->get_column('date');

  return $value;
}


=head2 datetime

GET created_at of the Logintry

=cut

sub datetime
{
  my $self = shift;

  my $value;
  my $field = 'created_at';

  $value = $self->dbrecord->get_column('created_at');

  return $value;
}

=head2 url

GET url of the Logintry

=cut

sub url
{
  my $self = shift;

  my $value;
  my $field = 'url';

  $value = $self->dbrecord->get_column('url');

  return $value;
}


=head2 login_success

GET login_success of the Logintry

=cut

sub login_success
{
  my $self = shift;

  my $value;
  my $field = 'login_success';

  $value = $self->dbrecord->get_column('login_success');

  return $value;
}

=head2 user_agent

GET user_agent of the Logintry

=cut

sub user_agent
{
  my $self = shift;

  my $value;
  my $field = 'user_agent';

  $value = $self->dbrecord->get_column('user_agent');

  return $value;
}

=head1 CREATE

=head2 create ($dbic,{ip_address,userid,date,login_success,user_agent})

Returns: (Object LoginTry,$ar_errors)

=cut

sub create
{
  my $dbic	=	shift;
  my $in_val	=	shift;

  my ($ip,$userid,$xdate,$login_success,$user_agent,$comments,$url,
     $tried_userid);
  {
    $ip		= $in_val->{ip_address};
    $xdate	= $in_val->{date};
    $login_success = $in_val->{login_success} || 'f';
    $user_agent = $in_val->{user_agent};
    $comments	= $in_val->{comments};
    $url	= $in_val->{url};
    $tried_userid = $in_val->{tried_userid};
  }

  my $table_latt = $dbic->resultset('Loginattempt');

  my ($row,$l_ltry,$ar_errors);

  try {

    $row = $table_latt->create($in_val);

    if (defined($row))
    {
      $l_ltry = Class::Logintry->new($dbic,$row);
    }

  };

  return ($l_ltry,$ar_errors);

}

=head2 key_invalid($dbic,$i_guava,[{$i_jamun,ip,epoch,authtype,url}])

Used By Class::Key::check_auth_keys

Store Details if API Access has been requested with InValid Keys

=cut

sub key_invalid
{
  my $dbic	=	shift;
  my $i_guava	=	shift;
  my $h_in	=	shift;

  my $list_errors;

  my ($in_ip,$in_epoch,$in_authtype,$i_jamun,$in_xdate,$in_url);
  {
    $i_jamun	= $h_in->{key};
    $in_ip	= $h_in->{ip};
    $in_xdate	= $h_in->{date};
    $in_epoch	= $h_in->{in_epoch};##Nonce
    $in_authtype= $h_in->{authtype};##AuthType,HMAC,etc
    $in_url	= $h_in->{url};
  }

  my $err_msg = "WARNING INVALID KEYS: id:$i_guava, key:$i_jamun,".
      " ip:$in_ip, URL:$in_url ";
  $list_errors = push_errors($list_errors,$c_err_invalid_apikey,$err_msg);
  print_errors($list_errors);

  my $h_val;
  {
    $h_val->{comments}	= $err_msg;
    $h_val->{url}	= $in_url;
    $h_val->{date}	= $in_xdate;
    $h_val->{user_agent}= 'APIKEY';
    $h_val->{login_success} = 'f';
    $h_val->{ip_address}	= $in_ip;
  }

  my $o_ltry = Class::Logintry::create($dbic,$h_val);

  return $o_ltry;

}


=head2 login_invalid_request($dbic,$h_in)

Returns: $o_ltry

Store details if an unknown/not permitted page has been requested through
browser.

=cut

sub login_invalid_request
{
  my $dbic	=	shift;
  my $h_in	=	shift;

  my $list_errors;

  my ($in_ip,$in_epoch,$in_user_agent,$in_xdate,$in_url,$i_user);
  {
    $in_ip	= $h_in->{ip};
    $in_xdate	= $h_in->{date};
    $in_epoch	= $h_in->{in_epoch};##Nonce
    $in_user_agent= $h_in->{user_agent};##User_agent,HMAC,etc
    $in_url	= $h_in->{url};
    $i_user	= $h_in->{userid};
  }


  my $err_msg = "WARNING INVALID PAGE REQUEST: User:$i_user ".
      " ip:$in_ip, URL:$in_url ";
  $list_errors = push_errors($list_errors,$c_err_invalid_request,$err_msg);
  print_errors($list_errors);

  my $h_val;
  {
    $h_val->{comments}	= $err_msg;
    $h_val->{url}	= $in_url;
    $h_val->{date}	= $in_xdate;
    $h_val->{user_agent}= $in_user_agent;
    $h_val->{login_success}	= 'f';
    $h_val->{ip_address}	= $in_ip;
    $h_val->{userid}		=	$i_user;
  }

  my $o_ltry = Class::Logintry::create($dbic,$h_val);

  return $o_ltry;

}

=head2 user_pass_invalid($dbic,$h_in)

Returns: $o_ltry

Store details if an unknown/not permitted page has been requested through
browser.

=cut

sub user_pass_invalid
{
  my $dbic	=	shift;
  my $h_in	=	shift;

  my $list_errors;

  my ($in_ip,$in_epoch,$in_user_agent,$in_xdate,$login_success,
      $in_url,$i_user,$i_password);
  {
    $in_ip	= $h_in->{ip};
    $in_xdate	= $h_in->{date};
    $in_epoch	= $h_in->{in_epoch};##Nonce
    $in_user_agent= $h_in->{user_agent};##User_agent,HMAC,etc
    $in_url	= $h_in->{url};
    $i_user	= $h_in->{userid};
    $login_success = $h_in->{login_success};
  }


  my $err_msg = "WARNING INVALID LOGIN : User:$i_user ".
      " ip:$in_ip, URL:$in_url ";
  $list_errors = push_errors($list_errors,$c_err_invalid_request,$err_msg);
  print_errors($list_errors);

  my $h_val;
  {
    $h_val->{comments}	= $err_msg;
    $h_val->{url}	= $in_url;
    $h_val->{date}	= $in_xdate;
    $h_val->{user_agent}= $in_user_agent;
    $h_val->{login_success}	= 'f';
    $h_val->{ip_address}	= $in_ip;
    $h_val->{tried_userid} = $i_user;
  }

  my $o_ltry = Class::Logintry::create($dbic,$h_val);

  return $o_ltry;

}

=head2 login_valid($dbic,$h_in)

Returns: $o_ltry

Store details if an unknown/not permitted page has been requested through
browser.

=cut

sub login_valid
{
  my $dbic	=	shift;
  my $h_in	=	shift;

  my $list_errors;

  my ($in_ip,$in_epoch,$in_user_agent,$in_xdate,$login_success,
      $in_url,$i_user,$i_password);
  {
    $in_ip	= $h_in->{ip};
    $in_xdate	= $h_in->{date};
    $in_epoch	= $h_in->{in_epoch};##Nonce
    $in_user_agent= $h_in->{user_agent};##User_agent,HMAC,etc
    $in_url	= $h_in->{url};
    $i_user	= $h_in->{userid};
    $login_success = 't';
  }


  my $err_msg = "VALID LOGIN : User:$i_user ".
      " ip:$in_ip, URL:$in_url ";
  $list_errors = push_errors($list_errors,$c_err_invalid_request,$err_msg);
  print_errors($list_errors);

  my $h_val;
  {
    $h_val->{comments}		= $err_msg;
    $h_val->{url}		= $in_url;
    $h_val->{date}		= $in_xdate;
    $h_val->{user_agent}	= $in_user_agent;
    $h_val->{login_success}	= $login_success;
    $h_val->{ip_address}	= $in_ip;
    $h_val->{userid}		= $i_user;
  }

  my $o_ltry = Class::Logintry::create($dbic,$h_val);

  return $o_ltry;

}



1;

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
GPLv3. Copyright tirveni@udyansh.org

=cut
