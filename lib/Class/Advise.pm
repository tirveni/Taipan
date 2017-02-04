#!/usr/bin/perl -w
#
# Class/Advise.pm
#
#
#created on 2017-02-04
#Tirveni Yadav
#

package Class::Advise;

use Moose;
use namespace::autoclean;

use TryCatch;


use Class::Utils qw(today now trim unxss valid_date push_errors print_errors valid_boolean);


our $VERSION = "1.00";

=head1 Advise

Advise handles user notification: using tables NotifyType,Notification,UserNotigied.


=head2 new($dbic,$notifyid)

Create Advise Object

=cut

sub new
{

  my $class	= shift;
  my $dbic	= shift;
  my $arg_notifyid   = shift;

  my $m = "C::Loge->new";

  my $row    = $arg_notifyid;

  unless ( ref($arg_notifyid) )
  {
    $arg_notifyid = unxss($arg_notifyid);
    if ($arg_notifyid)
    {
      my $rs_logex = $dbic->resultset('Notification');
      $row	   = $rs_logex->find($arg_notifyid);
    }
  }

  return (undef)
    unless $row;

  my $self		= bless( {}, $class );
  $self->{notify_dbrecord}	= $row;

  return $self;

}

#END method new

=head2 dbrecord

Return the DBIx::Class::Row object for this Artcile. Get the database object.

=cut

sub dbrecord
{
  my $self = shift;

  return ( $self->{notify_dbrecord} );

}

#End method create

=head2 notifyid

get NotifyID of the Advisory

=cut

sub notifyid
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'notifyid';
  my $value = $self->dbrecord->get_column($field);

  return $value;

}


=head2 type

get Type of the Advisory

=cut

sub type
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'type';
  my $value = $self->dbrecord->get_column($field);

  return $value;

}


=head2 message

get Message of the Advisory

=cut

sub message
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'message';
  my $value = $self->dbrecord->get_column($field);

  return $value;

}



=head2 active

get Active of the Advisory

Boolean: t/f

=cut

sub active
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'active';
  my $value = $self->dbrecord->get_column($field);
  $value = valid_boolean($value);

  return $value;

}


=head2 user_confirmation

get User_confirmation of the Advisory

Boolean: t/f

=cut

sub user_confirmation
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'user_confirmation';
  my $value = $self->dbrecord->get_column($field);
  $value = valid_boolean($value);

  return $value;

}



=head2 email_required

get Email_required of the Advisory

Boolean: t/f

=cut

sub email_required
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'email_required';
  my $value = $self->dbrecord->get_column($field);
  $value = valid_boolean($value);

  return $value;

}


=head2 mobile_required

get Mobile_required of the Advisory

Boolean: t/f

=cut

sub mobile_required
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'mobile_required';
  my $value = $self->dbrecord->get_column($field);
  $value = valid_boolean($value);

  return $value;

}


=head2 active_from

get Active_from of the Advisory

=cut

sub active_from
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'active_from';
  my $value = $self->dbrecord->get_column($field);

  return $value;

}



=head2 active_till

get Active_till of the Advisory

=cut

sub active_till
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'active_till';
  my $value = $self->dbrecord->get_column($field);

  return $value;

}


=head2 created_at

get Created_at of the Advisory

=cut

sub created_at
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'created_at';
  my $value = $self->dbrecord->get_column($field);

  return $value;

}



=head2 update_userid

get Update_userid of the Advisory

=cut

sub update_userid
{
  my $self = shift;

  #Return the name of the Buser
  my $field = 'update_userid';
  my $value = $self->dbrecord->get_column($field);

  return $value;

}

=head1 OPERATIONS


=head2 get_notifications($dbic, {active,role})

Get Notifications for Current Time. By Default only Active.

=cut

sub get_notifications
{
  my $dbic	= shift;
  my $in_vals	= shift;

  my $fn = "C/advise/get_notifications";

  my $is_active = $in_vals->{active};
  $is_active = valid_boolean($is_active);

  my $t_not = $dbic->resultset('Notification');
  my $today_now = Class::Utils::today_now_utc;

  ##Rs Notifications
  my $rs_not  = $t_not->search
    (
     {
      active_from => {'<=',$today_now},
      active_till => {'>',$today_now},
     }
    );

  ##If Active
  if ($is_active)
  {
    $rs_not = $rs_not->search({active => $is_active });
  }
  else
  {
    $rs_not = $rs_not->search({active => 't'});
  }

  #print "$fn RS: $rs_not \n";

  return $rs_not;

}


=head2 users_notified($dbic)

Returns: RS of Users Notified

=cut

sub users_notified
{
  my $self	= shift;
  my $dbic	= shift;

  my $h_vals;
  my $row_notify	= $self->dbrecord;

  my $m = "C/advise->users_notified";

  my $rs_notify_done;

  {
    $rs_notify_done = $row_notify->search_related
      ('usernotifieds',undef);
  }

  return $rs_notify_done;

}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut

1;
