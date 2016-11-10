#!/usr/bin/perl -w
#
# Class/Appuser.pm

#
# created on 2015-07-10
# Tirveni Yadav
# Version 1.1

package Class::Appuser;

use Moose;
use namespace::autoclean;

our $VERSION = "1.1";

#
#  The use namespace::autoclean bit is simply good code hygiene, as it
#  removes imported symbols from your class's namespace at the end of
#  your package's compile cycle, including Moose keywords. Once the
#  class has been built, these keywords are not needed.
#


use Digest::SHA qw/sha1_hex/;
use String::MkPasswd qw(mkpasswd);  # To generate Random Password.
use TryCatch;

##
use Class::Utils qw(unxss get_random_string);
use Class::Rock;



use Class::Key;
use Class::Utils
  qw(makeparm selected_language unxss unxss_an valid_email
     chomp_date valid_date get_array_from_argument trim user_login);



=head1 Appuser

=cut

my ($o_redis,$c_prefix_key_appuser,$c_expire_inmin,$c_expire_inhour);
{
  $o_redis = Class::Utils::get_redis;
  $c_prefix_key_appuser =  $Class::Rock::red_prefix_hash_appuser;
  $c_expire_inmin	= $Class::Rock::seconds_amin || 60;
  $c_expire_inhour	= $Class::Rock::seconds_inhour || 3600;
}

=pod

=head1 NAME

Class::Appuser - Utilities for handling appuser-related data

=head1 SYNOPSIS

use Class::Appuser;
    $o_appuser		= Class::Appuser->new( $dbic, $userid );
    $userid	        = $o_appuser->userid;
    $name	        = $o_appuser->aname;

    Appuser Object is hybrid of PG and Redis.


=head1 METHODS

=over

=item B<new( $dbic, $userid )>

Accept a appuser (either as a userid or as a DBIx::Class::Row
object and create a fresh Class::Appuser object from it. 

Return the Class::Appuser object, or undef if the Business couldn't be found.

=cut

sub new
{
  my $class		= shift;
  my $dbic		= shift;
  my $arg_userid	= shift;

  my $m = "C/Appuser->new";

  my $row;
  $row    = $arg_userid;

  my ( $userid,$o_redis,$r_hash_appuser,$already_existing);

  try
  {
    if (ref($arg_userid))
    {
      $userid = $row->get_column('userid');
    }
    else
    {
      $userid = $arg_userid;
    }

    #print "$m UserID:$userid \n";
    $userid = trim($arg_userid);

    $o_redis = Class::Utils::get_redis;
    $r_hash_appuser = "$c_prefix_key_appuser:$userid";
    $already_existing =
      $o_redis->hexists($r_hash_appuser,'userid');

   if ($already_existing)
    {
      my $refresh_reqd = Class::Appuser::is_stale($userid);
      if ($refresh_reqd > 0)
      {
	$already_existing = undef;
      }##Comparison IF

    }

    if (!$already_existing)
    {
      my $in_h = {userid=>$userid};
      $row = get_dbrow($dbic,$userid);
      #print "$m Row:$row \n";

      if (defined($row))
      {
	red_set_user($row);
	$already_existing =
	  $o_redis->hexists($r_hash_appuser,'userid');
      }
    }

    ##Still Doesn't Exist
    if (!$already_existing)
    {
      ##Nothing If Row is also not available
      return undef;
    }
  }

  my $self = bless( {}, $class );
  $self->{data}                         = $r_hash_appuser;
  $self->{redis} = $o_redis;
  $self->{db_object}                    = $dbic;
  return ($self);

}


=head2 get_dbrow

Function

Returns: the DBIx::Class::Row object for this DB Product
Get the database object.

=cut

sub get_dbrow
{
  my $dbic			= shift;
  my $arg_userid		= shift;

  my $fn = "B/Appuser::get_dbrow";

  my $rs_appuser = $dbic->resultset("Appuser");
  my $row;
  {
    $row          = $rs_appuser->find
      (
       {
        userid        => $arg_userid,
       }
      );
  }
  #print "$fn $dbic Row:$row \n";
  return ( $row );

}

=head2 red_set_user($row_appuser)

Arguments: ($row_appuser)

For Edit:

=cut

sub  red_set_user
{

  my $row_appuser = shift;

  my $fn = "C/Appuser::red_set_bizapp";

  my $f_userid   = 'userid';
  my $f_updated  = 'updated_epoch'; 
  my $v_userid   = $row_appuser->get_column($f_userid);
  $v_userid      = trim($v_userid);

  if ($v_userid)
  {
    my $red_key = "$c_prefix_key_appuser:$v_userid";

    my %rowh = $row_appuser->get_columns();

    foreach my $column (keys %rowh)
    {
      # do whatever you want with $key and $value here ...
      $column   = trim($column);
      my $value = $rowh{$column};
      $value    = trim($value);

      #print "$fn =>$column/$value.\n";
      if ($column ne 'verification_code' && $column ne 'password' )
      {
	if (defined($value))
	{
	  $o_redis->hset($red_key,$column,$value);
	}
	else
	{
	  $o_redis->hdel($red_key,$column);
	}

      }
    }

    my $epoch_time = time;
    $o_redis->hset($red_key,$f_updated,$epoch_time);
    $o_redis->expire($red_key,$c_expire_inhour);

  }

}

=head2 is_stale

Returns: True if Older than an Minute.

=cut

sub is_stale
{
  my $userid      =  shift;

  my $red_key		= "$c_prefix_key_appuser:$userid";
  my $f_updated		= 'updated_epoch';

  my $refresh_reqd	= 0;
  my $current_time	= time;
  my $seconds_inmin	= $c_expire_inmin || 60;

  my $local_epoch = $o_redis->hget($red_key,$f_updated);

  my $older_than_min = 0;
  if ($local_epoch)
  {
    my $local_plus_min = ($local_epoch + $seconds_inmin) ;
    $older_than_min = 1
      if($local_plus_min < $current_time);
  }

  if ($older_than_min > 0)
  {
    $refresh_reqd = 1;
  }

  return $refresh_reqd;

}


#=head2 red_set_user($row_appuser)

#Arguments: ($row_appuser)

#For Edit:

#=cut

#sub xred_set_user
#{
#  my $row_appuser = shift;

#  my $f = "C/appuser::red_set_user";

#  my ($f_userid,$f_name,$f_details,$f_email,
#      $f_date_joined,$f_active,$f_role,$f_dob,$f_sex,$f_verification_code);

#  {
#    $f_userid	= 'userid';
#    $f_name	= 'name';
#    $f_details	= 'details';
#    $f_date_joined	= 'date_joined';
#    $f_active	= 'active';
#    $f_role	= 'role';
#    $f_dob	= 'dob';
#    $f_sex	= 'sex';
#    $f_email	= 'email';
#    $f_verification_code = 'verification_code';
#  }

#  my ($v_userid,$v_name,$v_details,$v_email,
#      $v_date_joined,$v_active,$v_role,$v_dob,$v_sex,$v_verification_code);

#  {
#    $v_userid	= trim($row_appuser->get_column($f_userid));
#    $v_name	= trim($row_appuser->get_column($f_name));
#    $v_details	= trim($row_appuser->get_column($f_details));
#    $v_date_joined	= trim($row_appuser->get_column($f_date_joined));
#    $v_active	= trim($row_appuser->get_column($f_active));
#    $v_role	= trim($row_appuser->get_column($f_role));
#    $v_dob	= trim($row_appuser->get_column($f_dob));
#    $v_sex	= trim($row_appuser->get_column($f_sex));
#    $v_verification_code	= 
#      trim($row_appuser->get_column($f_verification_code));
#    $v_role	= trim($row_appuser->get_column($f_role));
#    $v_email	= trim($row_appuser->get_column($f_email));

#  }
#  #print "$f $c_prefix_key_appuser \n";

#  if($v_userid)
#  {

#    my $key = "$c_prefix_key_appuser:$v_userid" if($v_userid);

#    $o_redis->hset($key,$f_userid,$v_userid) ;
#    $o_redis->hset($key,$f_name,$v_name)		if($v_name);
#    $o_redis->hset($key,$f_details,$v_details)	if($v_details);
#    $o_redis->hset($key,$f_date_joined,$v_date_joined) if($v_date_joined);
#    $o_redis->hset($key,$f_active,$v_active)		if($v_active);
#    $o_redis->hset($key,$f_role,$v_role)		if($v_role);
#    $o_redis->hset($key,$f_dob,$v_dob)		if($v_dob);
#    $o_redis->hset($key,$f_sex,$v_sex)		if($v_sex);
#    $o_redis->hset($key,$f_email,$v_email)	if($v_email);
#    $o_redis->hset($key,$f_verification_code,$v_verification_code) 
#      if ($v_verification_code);
#    $o_redis->expire($key,$c_expire_inmin);
#  }
#}


=head2 db_object

Returns The $dbic object

=cut

sub db_object
{
  my $self      = shift;
  return ( $self->{db_object} );

}


#=head2 dbrecord

#Return the DBIx::Class::Row object for this Appuser.Get the database object.

#=cut

#sub dbrecord
#{
#  my $self = shift;
#  return ( $self->{appuser_dbrecord} );
#}
##END dbrecord

=head2 create ($dbic,$pars)

Create new User.

Arguments: Hash

Returns: $o_appuser

Default Role: is GUEST

=cut

sub create
{
  my $dbic      = shift;
  my $pars      = shift;

  my $rs	= $dbic->resultset('Appuser');

  $pars->{role} = 'GUEST';

  my $mrec = $rs->find_or_create($pars);
  my $o_appuser;
  red_set_user($mrec);

  {
    my $userid = $mrec->get_column('userid');
    $o_appuser = Class::Appuser->new( $dbic, $userid );
  }

  return ($o_appuser );

}
#END Create

=head2 create_with_pass ($context , $attribs)

This method generates a password for the User (Role client).

=cut

sub create_with_pass
{
  my $dbic	= shift;
  my $attribs	= shift;

  my $user_obj ;
  my $fx = "C/Appuser/create_with_pass";

  my $str_password = mkpasswd(-length=>15);
  #print "$fx passwd: $str_password \n";

  my $userid  = $attribs->{userid};
  $user_obj = Class::Appuser->new($dbic,$userid);

  $attribs->{password}	= $str_password;
  $attribs->{role}	= 'GUEST';
  $attribs->{active}	= 't';

  $user_obj = Class::Appuser::create($dbic,$attribs)
    if(! $user_obj );
  #print "$fx User:$user_obj,$userid \n";

  return $user_obj;

}

=head1 EDIT

=head2 edit($dbic,$h_vals)

Edit User

=cut

sub edit
{
  my $self	= shift;
  my $dbic	= shift;
  my $h_vals	= shift;

  my $m = "C/appuser->edit";
  my $userid = $self->userid;
  my $updated = 0;

  my ($a_password,$b_password,$in_current_pass,$in_enc_password);
  {
    $a_password = trim($h_vals->{passwordx});
    $b_password = trim($h_vals->{passwordy});
    $in_current_pass = trim($h_vals->{passwordc});
  }

  my ($name,$dob,$email,$details);
  {
    $email	= trim($h_vals->{email});
    $name	= unxss($h_vals->{name});
    $dob	= unxss($h_vals->{dob});
    $details	= unxss($h_vals->{details});
    print "$m Info Name:$name/$dob/$email/$details \n";
  }

  my $row_user = Class::Appuser::get_dbrow($dbic,$userid);

  if (defined($row_user))
  {
    ##--- Password is Edited Here
    if ($a_password && $b_password && $in_current_pass)
    {
      print "$m Update Password:$a_password \n";
      $updated = $self->change_password
	($row_user,$in_current_pass,$a_password,$b_password);
    }

    if (defined($name))
    {
      print "$m Update Name: $name \n";
      $row_user->name(	$name) if($name);
      $row_user->dob(	$dob) if($dob);
      $row_user->email(	$email) if($email);
      $row_user->details($details) if($details);
      $updated++;
    }

    $row_user->update;
    Class::Appuser::red_set_user($row_user);

  }

  $updated;

}

=head2 change_password($row_appuser,$row_appuser,$current_password,
$password_a,$password_b)

Edit Password.

Password Encoding is done here.

=cut

sub change_password
{
  my $self		= shift;
  my $row_appuser	= shift;
  my $current_password	= shift;##To be provided by User
  my $a_password	= shift;
  my $b_password	= shift;

  my $updated;

  if ($current_password && $a_password && $b_password)
  {
    my $in_enc_password =
      Class::Appuser::encode_password($current_password);

    my $e_stored_password = $row_appuser->password;

    if ($in_enc_password eq $e_stored_password)
    {
      my $new_password = Class::Appuser::encode_password($a_password);
      $updated = set_password($row_appuser,$new_password);
    }
  }

  return $updated;

}

=head2 set_password($row_appuser,$password)

Basic Level Password Change Function

=cut

sub set_password
{
  my $row_appuser	= shift;
  my $password		= shift;

  my $updated;
  if(defined($row_appuser) && $password)
  {
    $row_appuser->password($password);
    $updated = $row_appuser->update;
  }

  return $updated;

}

=head2 reset_password()

Return: the New Password.

=cut

sub reset_password
{
  my $self	= shift;

  my $str_password = mkpasswd(-length=>10);
  my $enc_password = Class::Appuser::encode_password($str_password);

  my $dbic = $self->db_object;
  my $userid = $self->userid;

  my $row_appuser	= Class::Appuser::get_dbrow($dbic,$userid);
  my $updated		=
    Class::Appuser::set_password($row_appuser,$enc_password);

  return $str_password;

}

=head1 Get/Set methods

=head2 userid

Returns: UserID

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

=head2 aname

Returns: Get name of the User

=cut

sub aname
{
  my $self  = shift;

  my $value;
  my $field = 'name';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 phone

Returns: Get phone of the User

=cut

sub phone
{
  my $self  = shift;

  my $value;
  my $field = 'phone';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 dob

Returns: Get dob of the User

=cut

sub dob
{
  my $self  = shift;

  my $value;
  my $field = 'dob';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 sex

Returns: Get sex of the User

=cut

sub sex
{
  my $self  = shift;

  my $value;
  my $field = 'sex';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 details

Returns: Get details of the User

=cut


sub details
{
  my $self  = shift;

  my $value;
  my $field = 'details';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}

=head2 email

Returns: Get email of the User

=cut


sub email
{
  my $self  = shift;

  my $value;
  my $field = 'email';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}



=head2 date_joined

Returns: Get date_joined of the User

=cut

sub date_joined
{
  my $self = shift;

  my $value;
  my $field = 'date_joined';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}
#END method date_joined

=head2 verification_code($boolean_generate)

Returns the verification Code.

SET

=cut

sub verification_code
{
  my $self = shift;
  my $boolean_generate = shift;

  my $db_verification_code;

  if(!$db_verification_code && $boolean_generate)
  {

    my $random	= Class::Utils::get_random_string();
    $random	= substr($random,0,31);
    $random	= unxss_an($random);
    my $userid = $self->userid;

    my $dbic = $self->db_object;
    ##Search
    my $rs_appuser = $dbic->resultset('Appuser');
    my $row_appuser = $rs_appuser->find({userid => $userid});
    ##Update
    $row_appuser->update({verification_code => $random});
    red_set_user($row_appuser);


    $db_verification_code = $random;

  }

  my $value;
  my $field = 'verification_code';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  $db_verification_code	= $value;


  return $db_verification_code;
}

=head2 set_active

Argument: t/f

=cut

sub set_active
{
  my $self   = shift;
  my $active = shift;

  my $m = "C/appuser->set_active";
  my $row_appuser;
  if(!$self || !$active)
  {
    return undef;
  }
  elsif($active eq 't' || $active eq 'f' )
  {
    my $userid = $self->userid;
    my $dbic = $self->db_object;
    my $rs_appuser = $dbic->resultset('Appuser');

    print "$m $active \n";
    ##Search
    $row_appuser = $rs_appuser->find({userid => $userid});
    ##Update
    $row_appuser->update({active => $active})
      if(defined($row_appuser));
    red_set_user($row_appuser);
  }

  return $active;

}

=head2  active

Get/Set active status of the User

Returns: Boolean Status([t/f])

=cut

sub active
{
  my $self   = shift;
  my $active = shift;

  my $row_appuser;
  if($active )
  {
    self->set_active($active);
  }

  my $value;
  my $field = 'active';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  return $value;

}


=head2 set_role

SET role of the User

=cut

sub set_role
{
  my $self = shift;
  my $role = shift;

  my $r_role = trim($role);

  try
  {
    my $userid = $self->userid;
    my $dbic = $self->db_object;
    my $rs_appuser = $dbic->resultset('Appuser');

    ##Search
    my $row_appuser = $rs_appuser->find({userid => $userid});

    ##Update
    $row_appuser->update({role => $r_role})
      if (defined($row_appuser));
    red_set_user($row_appuser);
  };


  $r_role = $self->role;

  return $r_role;

}



=head2 role_guest

SET role of the User

=cut

sub role_guest
{
  my $self = shift;

  my $c_role ='GUEST';
  my $r_role = $self->set_role($c_role);
  return $r_role;

}


=head2 role

get role of the User

=cut

sub role
{
  my $self  = shift;

  my $value;
  my $field = 'role';
  my $data  = $self->{data};

  $value = $o_redis->hget($data,$field);
  $value = trim($value);

  return $value;

}
#END method role

=head2 role_name($dbic)

Returns: Role Name of the User

=cut

sub role_name
{
  my $self    = shift;
  my $dbic    = shift;

  my $user_role = $self->role;
  my $rs_roles	= $dbic->resultset('Roles');

  my $r_name;

  my $row_roles = $rs_roles->find( {role => $user_role,} );
  if ($row_roles)
  {
    $r_name = $row_roles->get_column('description');
  }

  return $r_name;

}

=head2 roles($dbic)

Returns: Red Array of Hash  {role,level,description}

This is a function.

=cut

sub roles
{
  my $dbic	=	shift;
  my $rs_roles	= $dbic->resultset('Role');

  $rs_roles = $rs_roles->search({'role'=> {'!=','UNKN'} });

  my @list;
  while ( my $row = $rs_roles->next() )
  {
    my $role = $row->role;
    $role	= trim($role);
    push(@list,
	 {
	  role		=> $role,
	  level		=> $row->level,
	  description	=> $row->description,
	 });

  }

  return \@list;
}

=head1 Authorisation

=head2 user_allowed($dbic,$i_action)

check if user is allowed to use this action.

=cut

sub user_allowed
{
  my $self	= shift;
  my $dbic	= shift;
  my $i_action	= shift;

  my $rs	= $dbic->resultset('Access');

  ##
  my $m = "C/appuser->user_allowed";
  my $role   = $self->role;

  ##
  my $action = "/$i_action";
  print STDERR "$m  ROLE: $role CHECK: $action";

##Find if available in the HDB::Access
  my $row_access = $rs->find
    (
     {
       role => $role,
       privilege => $action,
      } 
    );

  return $row_access;

}
#END method user_allowed

=head2 privilege_exist($dbic,$i_action)

check if privilege exist is allowed to use this action

Returns the row_privilege

=cut

sub privilege_exist
{
  my $self		= shift;
  my $dbic		= shift;
  my $i_action		= shift;

  my $rs_privilege      = $dbic->resultset('Privilege');
  my $m			= "C/Appuser->privilege_exist";

  my $action = "/$i_action";
  #print STDERR "$m CHECK if $action exist in HDB \n";

  my $row_privilege ;

  if ($rs_privilege && $i_action)
  {
    $row_privilege = $rs_privilege->search( {privilege => $action,} );
    #print STDERR "$m: $row_privilege \n";
  }

  return $rs_privilege;


}
#END method privilege exist

=head2 url_allowed($dbic,$url)

Returns: 1 if allowed, 0 if not allowed.

=cut

sub url_allowed
{
  my $self	= shift;
  my $dbic	= shift;
  my $url	= shift;

  my $m = "C/appuser->url_allowed";

  my $user_role = $self->role;
  $url = trim($url);
  print "$m $dbic Role: $user_role, Url:$url. \n";

  my $rs_access = $dbic->resultset('Access');
  my $row_access;

  if (defined($rs_access))
  {
    $row_access = $rs_access->search
      (
       {
	role		=> $user_role,
	privilege	=> $url,
       },
      );
    print "$m Row: $row_access \n";
  }

  if ($row_access > 0)
  {
    return 1;
  }


  return;

}

=head1 Password/KEys

=item B<encode_password($password )>

Encode a plain-text password into the format required by the
Authentication module for storage in the DB.  Currently only handles
SHA-1 hashes.

Return the encoded password, which can be stored in the database.

=cut
# Encode a password
sub encode_password
{
  my
    $password = shift;

  if ($password)
  {
    use Digest::SHA qw/sha1_base64/;
    return( sha1_base64($password) );
  }

  return( undef );

}

=head1 API KEY

=head2 generate_key([$valid_till])

Arguments: Optional (Valid Till)

=cut

sub generate_key
{
  my $self	= shift;
  my $valid_till = shift;

  my $userid	= $self->userid;
  my $dbic	= $self->db_object;

  ##-- Disable Keys
  my $rs_appuserkey_disabled = $self->disable_all_keys();

  ##-- Generate New Key
  print "Date: $valid_till \n";
  my $row_appuserkey = Class::Key::set_auth_keys($dbic,$userid,$valid_till);

  return $row_appuserkey;

}

=head2 disable_all_keys

Functionality: Disable All Keys

Returns: Disabled Keys RS_appuserkey


=cut

sub disable_all_keys
{
  my $self	= shift;

  my $userid	= $self->userid;
  my $dbic	= $self->db_object;

  ##-- Disable Keys
  my $rs_appuserkey_disabled = Class::Key::disable_active_keys($dbic,$userid);

  return $rs_appuserkey_disabled;

}




=head2 api_key

Returns the Active Key for this User

=cut

sub api_key
{
  my $self	= shift;

  my $userid	= $self->userid;
  my $dbic	= $self->db_object;

  my $row_appuserkey = Class::Key::key_user($dbic,$userid);

  return $row_appuserkey;

}

=head1 TOKEN Access

=head2 generate_token([$valid_till])

Arguments: Optional (Valid Till)

=cut

sub generate_token
{
  my $self	 = shift;

  ##Make this At Most a Day Ahead.
  my $valid_till = shift;

  my $userid	= $self->userid;
  my $dbic	= $self->db_object;

  ##-- Generate New Key
  print "Date: $valid_till \n";
  my $row_appuserkey = Class::Key::set_token($dbic,$userid,$valid_till);

  return $row_appuserkey;

}

=head2 disable_all_tokens

Functionality: Disable All Keys

Returns: Disabled Keys RS_appuserkey


=cut

sub disable_all_tokens
{
  my $self	= shift;

  my $userid	= $self->userid;
  my $dbic	= $self->db_object;

  ##-- Disable Keys
  my $type = 'TOKEN';
  my $rs_appuserkey_disabled = 
    Class::Key::disable_active_keys($dbic,$userid,$type);

  return $rs_appuserkey_disabled;

}


=head1 REGISTRATION

=head2 validate_user($code)

If the Code matches then User is made Active. Used in New USer Registration.

Argument: $code

Returns: Boolean (Status[t/f])

=cut

sub validate_user
{
  my $self = shift;
  my $dbic = shift;
  my $in_code = shift;

  my $m = "C/appuser->validate_user";

  my ($db_verification_code);
  {
    my $userid		 = $self->userid;
    print "$m U: $userid \n";
    my $row_appuser	 = Class::Appuser::get_dbrow($dbic,$userid);

    $db_verification_code	=
      $row_appuser->get_column('verification_code')
	if($row_appuser);
  }

  my $active	= $self->active;

  ## print  "$m Validating User ".
  ##   "[$in_code == $db_verification_code] $active \n";

  if ( ($in_code eq $db_verification_code) && ($active eq 'f' || $active < 1))
  {
    #print "$m Validating User  $in_code, $db_verification_code \n";
    $self->set_active('t');
  }				#o_appuser

  return $self->active;

}


=head2 list($dbic)

Returns: RS of Appusers (not UNKN)

=cut

sub list
{
  my $dbic	= shift;

  my $table_users = $dbic->resultset('Appuser');
  $table_users    = $table_users->search({'userid'=> {'!=','UNKN'} });

  return $table_users;

}

no Moose;

=back

=cut

1;
