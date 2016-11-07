#!/usr/bin/perl -w
#
# Class/EMail.pm
#
# Methods for sending e-mail and SMS.
# Origin: is eloor/2008-10-04
#
use strict;

package Class::EMail;

use Email::Sender::Simple;
use Email::Sender::Simple qw(try_to_sendmail sendmail);
use Email::Sender::Transport::SMTP;
use TryCatch;


use Class::Utils qw(today now config maphash display_error);

=head1 NAME

EMail - Utility methods for sending e-mail and SMS.

=head1 SYNOPSIS

    use Class::EMail;
    my $mail = Class::EMail->new({to=>$recipient, subject=>$subject});
    $mail->body("some text");
    $mail->send;

=head1 DESCRIPTION

Class::EMail implements an OO interface for sending e-mail and SMS to
App users etc.  It gets the maximum amount of information it can
from the configuration file taipan.yml.

=head1 DATA

=over

=item B<<< $self->{smtp_server} >>>

=item B<<< $self->{sms_server} >>>

Store the default SMTP and SMS servers for this installation.

=cut

my ($smtp_server,$smtp_port,$smtp_username,$smtp_password);
my $sms_server;

BEGIN
{
  $smtp_server	 = config(qw/Internet email smtp-server/);
  $smtp_port	 = config(qw/Internet email smtp-port/);
  $smtp_username = config(qw/Internet email smtp-username/);
  $smtp_password = config(qw/Internet email smtp-password/);

  $sms_server = config(qw/Internet email sms-server/);


 }

=item B<<< $last_error >>>

Stores a string corresponding to the last error.

=cut

my
  $last_error = '';

=back

=head1 CONSTRUCTOR

=over

=item B<<< new({parameters}) >>>

Creates a new Class::EMail object and returns it to the caller.  The
e-mail parameters may be specified here or added through individual
methods later prior to sending the mail.

Parameters can be: from to subject body bcc sms.

=cut
# Create object
sub new
{
  my
    $proto = shift;
  my
    $class = ref($proto) || $proto;
  my
    $par = shift;
  my
    $self = {};
  foreach my $p( qw/from to subject body Debug bcc sms/ )
  {
    $self->{$p} = $par->{$p}
      if exists($par->{$p});
  }
  $self->{smtp_server} = $smtp_server;
  $self->{sms_server} = $sms_server;
  bless($self, $class);
  return( $self );
}

=back

=head1 GET/SET PARAMETERS

=over

=item B<<< from( [$from] ) >>>

=item B<<< to( [$to] ) >>>

=item B<<< subject( [$subject] ) >>>

=item B<<< body( [$body] ) >>>

=item B<<< bcc( [$bcc] ) >>>

Set the corresponding field if a value is specified.

Return the current value of the field.

=cut
sub from
{
  my
    $self = shift;
  my
    $from = shift;
  $self->{from} = $from
    if defined($from);
  return( $self->{from} );
}
sub to
{
  my
    $self = shift;
  my
    $to = shift;
  $self->{to} = $to
    if defined($to);
  return( $self->{to} );
}
sub subject
{
  my
    $self = shift;
  my
    $subject = shift;
  $self->{subject} = $subject
    if defined($subject);
  return( $self->{subject} );
}
sub body
{
  my
    $self = shift;
  my
    $body = shift;
  $self->{body} = $body
    if defined($body);
  return( $self->{body} );
}
sub bcc
{
  my
    $self = shift;
  my
    $bcc = shift;
  $self->{bcc} = $bcc
    if defined($bcc);
  return( $self->{bcc} );
}

=item B<<< is_sms >>>

Return TRUE if this is an SMS, false otherwise.

=cut
sub is_sms
{
  my
    $self = shift;
  return( exists($self->{sms}) && $self->{sms} );
}

=back

=head1 OPERATIONS

=over

=item B<<< send >>>

Send the prepared e-mail or SMS.  Return true on success or undef on
error.

=cut
# Send
sub send
{
  my $self	= shift;
  my $c		= shift;

  my $m = "C/EMail/send";
  $c->log->debug("$m ::Start Send Method ");

  #
  # Try to send
  my
    @bcc = ();			# Optional
  @bcc = (Bcc=>$self->bcc)
    if $self->bcc;

  my $debug = $self->{Debug} || 0;

  $c->log->debug("$m :SMTP $smtp_server,$smtp_port,".
		 "$smtp_username,$smtp_password ");
## Email Stuff

  my $transport = Email::Sender::Transport::SMTP->new
    ({
      host		=> $smtp_server,
      port		=> $smtp_port,
      sasl_username	=> $smtp_username,
      sasl_password	=> $smtp_password
     });

  my $email = Email::Simple->create
    (
     header => [
		To      => $self->to,
		From    => $self->from,
		Subject => $self->subject,
	       ],
     body => $self->body,
    );

  my $mail_err = try_to_sendmail($email,{transport=>$transport});

  if( $@ )
  {
    $last_error = $@;
    return( undef );
  }
  else
  {
    $last_error = '';
    return( 1 );
  }

}

=item B<<< send_message( $context, [$sms,] $from, $to, $subject,
$template, \%substitute [, $bcc] ) >>>

Send a mail or (if the second argument is 'SMS') SMS message.  $to may
be a scalar (single address) or an arrayref (for sending to multiple
addresses at the same time).

$template is the template file path.  \%substitute is a hashref
containing variables to be substituted in the template.

Return whatever $self->send returns.

=cut
# Send mail with given parameters
sub send_message
{
  my
    $class = shift;
  my
    $c = shift;
  my
    $sms = shift || '';
  my
    $from = $sms eq 'SMS' ?shift :$sms;
  my
    $to = shift;
  my
    $subject = shift;
  my
    $template = shift;
  my
    $substitute = shift;
  my
    $bcc = shift;
  # Set SMS flag
  $sms = ''
    unless $sms eq 'SMS';
  #
  # Get and substitute template
  my
    ($text, $template_subject) =
      Class::Utils::substitute_template_file($template, $substitute);
  $text = Class::Utils::concatenate_dot_signature($c, $text);
  # Get subject from the template if it has not been specified
  $subject = $template_subject
    unless $subject;
  # Get default sender if it has not been specified
  $from = Class::Utils::config(qw/Internet email noreply-email/)
    unless $from;
  #
  # Send the message
  my
    $msg = Class::EMail->new({sms=>$sms});
  $msg->from($from);
  $msg->to($to);
  $msg->subject($subject);
  $msg->body($text);
  $msg->bcc($bcc)
    if $bcc;
  if( $msg->send )
  {
    return( 0 );
  }
  else
  {
    return($msg->last_error);
  }
}

=back

=head1 SPECIFIC E-MAIL TYPES

=over

=item B<<< send_user_feedback( $context, $name, $email, $category,
$text ) >>>

Send a user feedback to the Taipan managers. $category is the
category of the feedback and $text is the actual feedback the user
provided.

$name and $email are the name and e-mail ID of the user.

=cut
# User feedback
sub send_user_feedback
{
  my
    $class = shift;
  my
    $c = shift;
  my
    $name = shift;
  my
    $email = shift;
  my
    $category = shift;
  my
    $text = shift;
  my
    $to = Class::Utils::config(qw/Company email/);
  my
    $from = $class->make_from_address($name, $email);
  my
    $subject = "Feedback from $name regarding $category";
  my
    %SUBSTITUTE = ();
  $SUBSTITUTE{FEEDBACK} = $text;
  $SUBSTITUTE{DATE} = today.' '.now;
  $SUBSTITUTE{SENDER} = $from;
  my
    $send = $class->send_mail
      ( $c, $from, $to, $subject, 'feedback-template',
	\%SUBSTITUTE);

  if( $send )
  {
    $c->log->info(<<END);
FAIL send feedback from $from
due to: $send
END
  }
}

=head1 send_mail_to_admin($c,$body,$in_subject)

Send mail to Software Admin

=cut

sub send_mail_to_admin
{
  my $c    = shift;
  my $body = shift;
  my $in_subject = shift;

  my $m = "C/EMail/send_mail_to_admin";

  my $today	= Class::Utils::today;
  my $now	= Class::Utils::now;

  my $today_now = "$today"."_"."$now";

#Subject
  my $default_subject = "MT:DYT $today $now";
  my $subject = $in_subject || $default_subject;

#Send mail info
  my $mailto = config(qw/Internet admin mail/);
  $c->log->debug("$m MailTo: $mailto ");

#SMTP to,From
  my $send_to   = $mailto;
  my $send_from = $smtp_username;

#Create Mail Object
  my $mail = Class::EMail->new
    ({to=>$send_to,subject=>$subject});

#Fill the Mail object
  $mail->from($send_from);
  $mail->to($send_to);
  $mail->subject($subject);
  $mail->body($body);

  $c->log->debug("$m EMAIL Obj: $mail Ready to be sent ");

#Send Mail
  $mail->send($c);


}


=head1 send_mail_to_customer($c,$body,$subject,$customer_email)

Send mail to Customer

=cut

sub send_mail_to_customer
{
  my $c			= shift;
  my $body		= shift;
  my $in_subject	= shift;
  my $customer_email		= shift;

  my $m = "C/EMail/send_mail_to_customer";

  my $today	= Class::Utils::today;
  my $now	= Class::Utils::now;

  my $today_now = "$today"."_"."$now";

  my
    $company_name = Class::Utils::config(qw/Company name/);

#Subject
  my $default_subject = "$company_name $today $now";
  my $subject = $in_subject || $default_subject;

#Send mail info
#SMTP to,From
  my $send_to   = $customer_email;
  $c->log->debug("$m MailTo: $customer_email ");
  my $send_from = $smtp_username;

#Create Mail Object
  my $mail = Class::EMail->new
    ({to=>$send_to,subject=>$subject});

#Fill the Mail object
  $mail->from($send_from);
  $mail->to($send_to);
  $mail->subject($subject);
  $mail->body($body);

  $c->log->debug("$m EMAIL Obj: $mail Ready to be sent ");

#Send Mail
  $mail->send($c);


}


=back

=head1 UTILITY METHODS

=over

=item B<<< last_error >>>

Return the last error (or empty)

=cut
# Last error
sub last_error
{
  my
    $class = shift;
  return( $last_error );
}

=item B<<< local_contact( $context ) >>>

Return the e-mail address of the local contact (e.g. Eloor Libraries
<delhi@eloor.in>).

=cut
# Local contact e-mail ID
sub local_contact
{
  my
    $class = shift;
  my
    $c = shift;

  my
    $local_contact_template
      = Class::Utils::config(qw/Company email/);
  return( "Administrator $local_contact_template" );
}

=item B<<< smtp_server >>>

=item B<<< sms_server >>>

Return the name of the SMTP or SMS server.

=cut
# SMTP/SMS servers
sub smtp_server
{
  my
    $class = shift;
  return( $smtp_server );
}
sub sms_server
{
  my
    $class = shift;
  return( $sms_server );
}

=item B<<< make_from_address( $name, $email ) >>>

Make a From: address of the form "NAME <EMAIL>" from the given
parameters.  Try to clean them up as much as possible.

=cut
sub make_from_address
{
  my
    $class = shift;
  my
    $name = shift;
  my
    $email = shift;
  #
  # Keep only legal stuff in the address, but be gentle (allow _, even
  # though it's not a legal e-mail character e.g.).
  $email =~ s/[^A-Za-z0-9_@.!-]//g;
  $name =~ s/[\\<>]//g;
  return( "$name <$email>" );
}

=back

=cut

1;
