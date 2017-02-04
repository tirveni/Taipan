#!/usr/bin/perl -w
#
# Class/Utils
#
# Utility methods for DB abstraction classes.
#
#
use strict;

package Class::Utils;

use Date::Manip;   ## Add_days,valid_date
use DateTime;      ## Good TimeZone Support Hence Here.
use Date::Calc;
use Date::Parse;


## Fast Date(add/subtract) Manipulation as this is
## in C Code.

use TryCatch;


use POSIX qw/strftime/;
use HTML::TagFilter;
use HTML::Entities;
#use Crypt::Cracklib; Instead use DataPassword
use Data::Password;
use Captcha::reCAPTCHA;
use Email::Valid;
use String::Random;


use Redis;
#
# Required for testing only
use IPC::SysV qw/IPC_CREAT/;

use vars qw(@ISA @EXPORT_OK);
require Exporter;

@ISA        = qw/Exporter/;
@EXPORT_OK  = qw/set_today today now today_now_utc
		 chomp_date chomp_time format_date
		 valid_date valid_time add_days delta_days
		 dates_increasing
		 date_time_utc utc_epoch
		 utc_datetime_to_epoch datetime_split
		 range_date_start range_date_end range_yyyy_mm
		 dates_range_intersect
		 display_error display_message
		 push_errors	print_errors
		 unxss unxss_an xnatural xfloat valid_email valid_int
		 date_search_hashref unxss_pk valid_boolean
		 round decimal_fmt
		 commify_series commify
		 user_login user muser
		 set_muser is_muser
		 check_password_strength generate_password
		 get_recaptcha validate_recaptcha
		 selected_language arg
		 sort_array intersection uniquearray aonly
		 get_keyval_from_arrayofhash str_in_array
		 makeparm
		 maphash myname trim int_or_string
		 get_array_from_argument
		 config get_random_string extract_digits
		 get_redis get_redis_queue redis_save_hash_field
		/;

=pod

=head1 NAME

Class::Utils - Utility methods

=head1 SYNOPSIS

    use Class::Utils;

See METHODS for list of methods available in this class.

=head1 DATE MANIPULATION

=over

=item B<set_today( $date )>

Set this if you want today to return a date other than the current
date.  Useful for testing.

Set to an empty value to resume using today's date.

=cut
# Value of today
sub set_today
{
  my
    $new_today = shift;
  my
    $shared_today = shmget(1161, 1024, IPC_CREAT|0600);
#print  STDERR "shared_today $shared_today\n";
  shmwrite($shared_today, $new_today, 0, 10);
#print STDERR "shared_today 2 $shared_today\n";
}

=item B<today_x>


Can be used with set_today, to test timings related stuff.

Return today's date as YYYY-MM-DD string.  If you set
Class::Utils::today earlier it will return that value.

=cut
# Get today's date
#
sub today_x
{
  my
    $shared_today = shmget(1161, 1024, IPC_CREAT|0600);
  my
    $today;
#print STDERR "TODAY: got SHM $shared_today\n";
  shmread($shared_today, $today, 0, 10);
#print STDERR "TODAY: got TODAY $today\n";
  if( $today gt '0' )
  {
    return( $today );
  }
  else
  {
    return( POSIX::strftime('%Y-%m-%d', localtime) );
  }
}


=item B<now>

Return the current time as HH:MM:SS.

=cut_x

# Get the time
sub now_x
{
  return( POSIX::strftime('%H:%M:%S', localtime) );
}

=head2 today

based on utc.

=cut

sub today
{
  my $c_today_now_utc   = Class::Utils::today_now_utc();
  my $c_today_utc	= chomp_date($c_today_now_utc);

  return $c_today_utc;


}

=head2 now

based on utc.

=cut now

sub now
{
  my $c_today_now_utc   = Class::Utils::today_now_utc();
  my $c_today_time      = chomp_time($c_today_now_utc);
  #yyyy-mm-dd hh-mm-ss
  #11-20

  return $c_today_time;
}


=item B<today_now_utc>

Return the Current Date and current time as Yyyy-mm-dd HH:MM:SS+0000.

=cut
# Get the time
sub today_now_utc
{
  my $time_zone	= 'UTC';    #Default Time Zone.
  my $o_dt	= DateTime->now(time_zone => $time_zone);

  my $today = $o_dt->ymd;
  my $now   = $o_dt->hms;
  my $today_now = "$today $now +0000";

  return $today_now;
}





=item B<chomp_date($date)>

Chop off everything from the date except the actual date part (initial
YYYY-MM-DD).

=cut
# Chomp date
sub chomp_date
{
  my
    $date = shift;
  return( substr($date, 0, 10) );
}

=item B<chomp_time($date)>

Chop off everything from the date except the actual date part (initial
YYYY-MM-DD).

=cut
# Chomp date
sub chomp_time
{
  my
    $date = shift;
  return( substr($date, 11, 20) );
}

=item B<<< format_date( $date ) >>>

Format a YYYY-MM-DD date as Month DD, YYYY

=cut
# Format a date into human-readable format
sub format_date
{
  my
    $date = shift;
  my
    ($yyyy, $mm, $dd) = split(/-/, chomp_date($date));
  my
    @month = (qw/NONE January February March April May June July August September
		 October November December/);
  return( "$month[$mm] $dd, $yyyy" );
}

=item B<<< valid_date( $date ) >>>

Return $date if it is a valid date, undef otherwise.  Remove any time
portion that may exist.

=cut
sub valid_date
{
  my
    $date = shift;

  my $fn = "C/utils/valid_date";

  ##Parse Date is unable to handle, T: 2016-07-01T00:00:00
  if (index(($date), ('T')) != -1)
  {
    $date = substr($date,0,10);
  }

  my $ydate = Date::Manip::ParseDate($date);
  my ($year, $month, $day) = Date::Manip::UnixDate
      ($ydate,"%Y","%m","%d") ;

  #print "$fn ($date => $ydate) $year-$month-$day \n";
#
#
#  $date = chomp_date($date);
#  #
#  # Check the format
#  return( undef )
#    unless (
#	    ($date =~ /\d\d\d\d-\d\d-\d\d/) ||
#	    ($date =~ /\d\d\d\d-\d-\d/)	    ||
#	    ($date =~ /\d\d\d\d-\d-\d\d/)   ||
#	    ($date =~ /\d\d\d\d-\d\d-\d/)
#	   )
#      ;

#  my ($year,$month,$day) = split(/-/,$date);

#  $year		= int($year);
#  $month	= int($month);
#  $day		= int($day);

#  if($month > 0 && $month < 10)
#  {
#    $month = "0$month";
#  }
#  if($day > 0 && $day < 10)
#  {
#    $day = "0$day";
#  }

  $date = "$year-$month-$day";
  my $valid = Date::Calc::check_date($year,$month,$day);

  if($valid) 
  {
    return( $date );
  }
  else
  {
    return( undef );
  }
}

=head2 valid_time($string)

Checks if String is Valid Time String.

Returns: (Time_12,Time_24)

Time Format If Time is in 12/24 Hour Format.

=cut

sub valid_time
{
  my $in_string = shift;

  my $fn = "U/valid_time";

  my ($a_hh,$a_mm) = substr($in_string,0,5);
  my $a_time = "$a_hh:$a_mm";

  my $is_time_12_24;

  if($a_time =~ /(?:0[0-9]|1[0-1]):[0-5][0-9]/ ||
     $a_time =~ /([01]?[0-9]|2[0-3]):[0-5][0-9]/
    )
  {
    $is_time_12_24 = 1;
    print "$fn $is_time_12_24 ($in_string) \n";
  }


  my ($valid_time,$time12);
  if ($is_time_12_24)
  {
    my $b_time = Date::Manip::ParseDate($in_string) ;
    ## print "$fn B. $b_time \n";

    my ($hour, $minute, $second,$h12,$ap) = Date::Manip::UnixDate
      ($b_time,"%H","%M","%S","%I","%p") ;

    my $c_time = Date::Calc::check_time($hour,$minute,$second);
    # print "$fn Valid: $c_time/$h12,$p \n";

    if ($c_time)
    {
      $valid_time = "$hour:$minute:$second";
      $time12	  = "$h12:$minute $ap";	
    }

  }

  return ($time12,$valid_time);

}

=head2 date_time_utc

Returns the Date Time Object for UTC.

=cut

sub date_time_utc
{
  my $time_zone	= 'UTC';    #Default Time Zone.
  my $o_dt	= DateTime->now(time_zone => $time_zone);

  return $o_dt;
}

=head2 utc_epoch

Returns: Integer, the Date Time Epoch for UTC.

=cut

sub utc_epoch
{
  my $time_zone	= 'UTC';    #Default Time Zone.
  my $o_dt	= DateTime->now(time_zone => $time_zone);
  my $epoch     = $o_dt->epoch;

  return $epoch;
}

=head2 datetime_split($in_datetime)

All of these Work

    my $xdate = "2016-02-03 04:05:06 -08:00";
    my $xdate = "2016-02-03T04:05:06 -08:00";
    my $xdate = "02-03-2016 04:05:06 -08:00";

If TimeZone is not given, then Local Machines Timezone is given.

=cut

sub datetime_split
{
  my $in_datetime = shift;

  my $fn = "C/Utils/datetime_split";

  my $ydate = Date::Manip::ParseDate($in_datetime);
  print "$fn In: $in_datetime => $ydate  \n";

  ##Assuming TimeZone is not in $in_datetime, then only it fails.
  ##HEnce add Default TimeZone.
  if (!$ydate)
  {
    my $xdate = "$in_datetime +0000";
    $ydate = Date::Manip::ParseDate($xdate);
    print "$fn In: $xdate => $ydate  \n";
  }


  my ($year, $month, $day, $hour, $min, $sec, $zone);

  my $full = Date::Manip::UnixDate($ydate,'%Y-%m-%d %H:%M:%S %z') ;
  #print "$fn In: $in_datetime => $ydate  => $full \n";
  if($ydate)
  {
    ($year, $month, $day, $hour, $min, $sec, $zone) = Date::Manip::UnixDate
      ($ydate,"%Y","%m","%d", "%H","%M","%S", "%z") ;
    #print "$fn $year-$month-$day $hour:$min:$sec  $zone \n";
  }

  return ($year, $month, $day, $hour, $min, $sec, $zone);
}

=head2 utc_datetime_to_epoch($datetime_utc)

Returns the Date Time Epoch for UTC.

=cut

sub utc_datetime_to_epoch
{
  my $datetime	=	shift;

  my $fn = "C/Utils/utc_datetime_to_epoch";
  my $epoch;

  my($year, $mon, $day, $hour, $min, $sec, $zone) =
    datetime_split($datetime);

  ##Date::Calc is faster as this in C
  $epoch = Date::Calc::Date_to_Time($year,$mon,$day, $hour,$min,$sec)
    if($year && $mon && $day);
  #print "$fn Epoch:$epoch \n";

  return $epoch;
}


=head2 add_days

Arguments: Date(yyyy-mm-dd),Days number

Return: Date

=cut

sub add_days
{
  my $date = shift;
  my $days = shift;

  my $added;
  #$date = chomp_date($date);
  #$added = Date::Manip::UnixDate
  #  (Date::Manip::DateCalc($date,"$days days",undef),'%Y-%m-%d') ;

  ##Should Be Faster
  my ($y1,$m1,$d1) = split(/-/,$date);
  my ($year,$month,$day) = Date::Calc::Add_Delta_Days
      ($y1,$m1,$d1,$days);

  $year = int($year);
  $month = int($month);
  $day = int($day);

  if($month > 0 && $month < 10)
  {
    $month = "0$month";
  }
  if($day > 0 && $day < 10)
  {
    $day = "0$day";
  }


  $added = "$year-$month-$day";

  return $added;
}

=head2 delta_dates(A2_date,A1_date)

Returns: Days Between A2 Date and A1 date.

IF A2 is greater than A1, then Returns in +ve. Else -ve.

=cut

sub delta_days
{
  my
    ($date1, $date2) = @_;
  $date1 = valid_date(chomp_date($date1));
  $date2 = valid_date(chomp_date($date2));

  my $delta_days;

  my ($a_yyyy,$a_mm,$a_dd) = split(/-/,$date1);
  my ($b_yyyy,$b_mm,$b_dd) = split(/-/,$date2);

  my @d1 = ($a_yyyy,$a_mm,$a_dd);
  my @d2 = ($b_yyyy,$b_mm,$b_dd);
  my $delta_days;
  $delta_days = Date::Calc::Delta_Days( @d2, @d1 ) if($date1 && $date2);

  return $delta_days;
}

=head2 dates_increasing(date_1,$date_2 [,$date_3])

Arguments: Dates

Returns: Integer(+ve) if dates are in increasing order

=cut

sub dates_increasing
{
  my $date_one	= shift;
  my $date_two	= shift;
  my $date_tri	= shift;

  my $f = "C/utils::date_increasing";
  my ($delta_one_two,$delta_two_tri) = 0;

  #print " A: $date_1, B: $date_2, C:$date_3\n";
  $delta_one_two = delta_days($date_two,$date_one) if($date_two && $date_one);
  $delta_two_tri = delta_days($date_tri,$date_two) if($date_tri && $date_two);
  #print " dA: $delta_12, dB: $delta_23 \n";

  my $increasing_order = 0;

  if ($date_tri)
  {
    if( $delta_two_tri  > 0 && $delta_one_two > 0 )
    {
      $increasing_order++;
    }
  }
  elsif ($delta_one_two > 0)
  {
    $increasing_order++;
  }

  return $increasing_order;
}

=head2 date_series_create($current_date,$lower [,$upper])

Period And Date Validation.  Sets the dates(Lower,Upper) if the dates
are not incrementing(higher than current)

Arguments: Dates(yyyy-MM-dd): $date_a,$date_b,date_c

Returns: ($lower_date,$upper_date) with Default Values

This is a Function: Business::Branch::date_series

For Use in Create ProductPrice,Create Tax. Not in Edit

=cut

sub date_series_create
{
  my $current	= shift;
  my $lower	= shift;
  my $upper	= shift;

  my $f = "B/branch::date_series";
  ##Valid Format
  $current	= valid_date($current) if($current);
  $lower	= valid_date($lower) if($lower);
  $upper	= valid_date($upper) if($upper);

  if (!$current || !$lower)
  {
    undef;
  }

  ##Delta Calculations
  my ($delta_current_lower,$delta_lower_upper);
  $delta_current_lower = Class::Utils::dates_increasing
    ($current,$lower)	if($current && $lower);
  $delta_lower_upper =  Class::Utils::dates_increasing
    ($lower,$upper)	if($lower && $upper);
  #print "DeltaA: $delta_curr_lower, DeltaB: $delta_lower_upper \n";

  print "$f Low: $lower, Current:$current, ".
    "Low Increase:$delta_current_lower \n";
  if ($current && $lower && $delta_current_lower < 1)
  {
    print "$f Lower:$lower Current:$current,".
      " Delta_increasing:$delta_current_lower, Hence Tomorrow \n";
    my $add_days = 1;
    $lower =  Class::Utils::add_days($current,$add_days);
    ##Everything has to be from Tomorrow.
  }


  ##--- If the Upper Date is before Today, Then Add 30 days to today.
  ##--- Or If Upper is not Given.

  if ($lower && $upper && $delta_lower_upper < 0)
  {
    print "$f Low: $lower, Up:$upper, Up Increasing:$delta_lower_upper,
     Hence Upper+Month  \n";
    my $add_days = 30;
   $upper = Class::Utils::add_days($lower,$add_days);
  }


  ##--- Allow single Day Range

  ##--- If the Gap is Zero, lower and upper are same, Allow.


  return ($lower,$upper);
}

=head2 date_replace($current_date,$date_old,$date_new)

Validate Lower Date, Anything for Future is allowed.

Arguments: Three Dates

Returns: Date

=cut

sub date_replace
{
  my $current	= shift;
  my $date_old	= shift;
  my $date_new = shift;

  my $message;
  my $f = "C/utils/date_replace";

  #print "$f Old:$date_old New:$date_new, current:$current: \n";

  $current	= valid_date($current)   if($current);
  $date_old	= valid_date($date_old) if($date_old);
  $date_new	= valid_date($date_new) if($date_new);

  my $value = $date_old;
  #print "$f Old:$date_old New:$date_new, current:$current: \n";

  if ($current && $date_old && $date_new && ($date_new ne $date_old))
  {
    my $curr_gt_old = Class::Utils::dates_increasing($current,$date_old);
    my $curr_gt_new = Class::Utils::dates_increasing($current,$date_new);

    ##If Editing is for Past, Then Do not Allow, 
    if ($curr_gt_old == 0)
    {
      $value = $date_old;##No Change
      $message = "$date_old, Old date is before Current Date.";
    }
    elsif ($curr_gt_new == 0 )
    {
      $value = $date_old;##No Change
      $message = "$date_new, New date is before Current Date.";
    }
    else
    {
      $value = $date_new;##Change if For Future.
    }
  }
  #print "$f Value: $value \n";
  return ($value,$message);

}

=head2 edit_future_range($current_date,{old_start,old_end,new_start,new_end})

Check if Range is in future.

Returns: ($errors,$new_start,$new_end)

=cut

sub edit_future_range
{
  my $current_day = shift;
  my $in_vals = shift;

  my $fn = "C/utils/edit_future_range";

  my ($old_start,$old_end);
  $old_start	= $in_vals->{old_start};
  $old_end	= $in_vals->{old_end};

  my ($new_start,$new_end);
  $new_start	= $in_vals->{new_start};
  $new_end	= $in_vals->{new_end};

  my ($errors);
  my ($today_in_range) = 1;


  if (($old_start ne $new_start) || ($old_end && $new_end))
  {
    print "$fn Old $old_start <> $old_end  \n";
    my ($from_msg,$till_msg);
    ##1. Sanitize Date
    if($old_start ne $new_start)
    {
      ($new_start,$from_msg)	=  Class::Utils::date_replace
	($current_day,$old_start,$new_start) ;
      push(@$errors,$from_msg);
    }

    ##Allow Current Date to be EndDate
    if ($new_end eq $current_day)
    {
      print "$fn Bringing End Date: to Today \n";
    }
    elsif ($old_end eq $current_day)
    {
      print "$fn Bringing End Date from Today to Future. \n";
    }
    elsif($old_end ne $new_end)
    {
      print "$fn Changin Till: Old:$old_end/New:$new_end  \n";
      ($new_end,$till_msg)	=  Class::Utils::date_replace
	($current_day,$old_end,$new_end);
      push(@$errors,$till_msg);
      print "$fn Changin Till: Old:$old_end/New:$new_end  \n";
    }

    print "$fn Replace $new_start <> $new_end  \n";
    ##2. Today Intersects with Period
    $today_in_range = Class::Utils::date_in_range
      ($current_day,$new_start,$new_end)
	if($current_day && $new_start && $new_end);
  }


  return ($errors,$new_start,$new_end);

}

=head2 time_in_range($a_hh_mm,$lower_hh_mm,$upper_hh_mm)

Finds out if time is in range or not.

=cut

sub time_in_range
{
  my $hm	= shift;
  my $lower	= shift;
  my $upper	= shift;

  my $sec_in_hour = 3600;
  my $sec_in_min  = 60;
  my ($lower_hh,$lower_mm) = split(/:/,$lower);
  my ($upper_hh,$upper_mm) = split(/:/,$upper);
  my ($h_hh,$h_mm)	   = split(/:/,$hm);

  $h_hh	= int($h_hh);
  $h_mm	= int($h_mm);
  $lower_hh = int($lower_hh);
  $lower_mm = int($lower_mm);
  $upper_hh = int($upper_hh);
  $upper_mm = int($upper_mm);


  if (
      $lower_hh > 24 ||  $lower_mm > 60 || $lower_mm < 0|| $lower_hh < 0
      ||
      $upper_hh > 24 ||  $upper_mm > 60 || $upper_hh < 0 || $upper_hh < 0
      ||
      $h_hh     > 24 ||   $h_mm > 60 ||    $h_hh < 0 || $h_hh < 0
     )
  {
    return undef;
  }

  my $seconds_lower = ($lower_hh * $sec_in_hour)+ ($lower_mm * $sec_in_min);
  my $seconds_upper = ($upper_hh * $sec_in_hour)+ ($upper_mm * $sec_in_min);
  my $seconds_hm    = ($h_hh * $sec_in_hour)    + ($h_mm * $sec_in_min);

  if ($seconds_hm >= $seconds_lower && $seconds_hm <= $seconds_upper)
  {
    return 1;
  }
  else
  {
    return 0;
  }

}


=head1 Range Functions for date.

=head2 date_in_range($date,$lower,$upper)

Arguments: Lower_date,Upper_date, $date

Format: yyyy-mm-dd

Returns: If date is within the range then 1, Else 0. 

And  -1 if Dates are wrong.

=cut

sub date_in_range
{
  my $date	= shift;
  my $dt_a	= shift;
  my $dt_b	= shift;

  my $f = "U::date_in_range";
  ##Valid Date
  $dt_a = valid_date($dt_a);
  $dt_b = valid_date($dt_b);
  $date = valid_date($date);
  if (!$dt_a || !$dt_b || !$date)
  {
    return -1;
  }

  ##Check which is the lower, and which is greater.
  my ($dt_lower,$dt_upper);
  my $delta = delta_days($dt_b,$dt_a);
  #print "$f Delta: $delta of $dt_a -> $dt_b \n";

  if ($delta > 0)
  {
    $dt_lower = $dt_a;
    $dt_upper = $dt_b;
  }
  else
  {
    $dt_lower = $dt_b;##B is the Lower
    $dt_upper = $dt_a;##A is the Upper
  }
  #print "$f Lower:$dt_lower/ Upper:$dt_upper ($date)\n";

  ##Range
  my ($a_yyyy,$a_mm,$a_dd) = split(/-/,$dt_lower);
  my ($z_yyyy,$z_mm,$z_dd) = split(/-/,$dt_upper);
  ##Date
  my ($x_yyyy,$x_mm,$x_dd) = split(/-/,$date);

  my ($lower,$upper);
  $lower = Date::Calc::Date_to_Days($a_yyyy,$a_mm,$a_dd);
  $upper = Date::Calc::Date_to_Days($z_yyyy,$z_mm,$z_dd);

  $date = Date::Calc::Date_to_Days($x_yyyy,$x_mm,$x_dd);
  #print "$f $lower/$upper :: $date \n";

  my $intersect = 0;
  if (($date >= $lower) && ($date <= $upper))
  {
    $intersect = 1;
  }
  #print "$f Intersect:$intersect \n";

  return $intersect;

}


=head2 dates_range_intersect($a_lower,a_upper, $z_lower, $z_upper)

Arguments: DT_A_lower,DT_A_upper, DT_Z_Lower,DT_Z_Upper

Returns: IF period of A and B Intersect.

=cut

sub dates_range_intersect
{
  my $a_lower	= shift;
  my $a_upper	= shift;

  my $z_lower	= shift;
  my $z_upper	= shift;

  my $f = "U::ranges_intersect";
  #print "$f $a_lower/$a_upper :: $z_lower/$z_upper \n";

  ##Check A in Z
  my ($a_lower_in,$a_upper_in);
  $a_lower_in = date_in_range($a_lower,$z_lower,$z_upper);
  $a_upper_in = date_in_range($a_upper,$z_lower,$z_upper);

  ##Reverse Also
  my ($z_lower_in,$z_upper_in);
  $z_lower_in = date_in_range($z_lower,$a_lower,$a_upper);
  $z_upper_in = date_in_range($z_upper,$a_lower,$a_upper);

  #print "$f $a_lower_in/$a_upper_in \n";
  my $intersect = 0;
  if ( ($a_lower_in  > 0)  || ( $a_upper_in > 0) ||
       ($z_lower_in >0) || ($z_upper_in > 0))
  {
    $intersect = 1;
  }

  print "$f Intersect:$intersect \n";
  return $intersect;
}


=head2 ranges_intersect_old(a_lower,a_upper, z_lower, z_upper)

Argument: Four Integers: a_lower,a_upper, z_lower, z_upper
 2nd_start, 2nd_end

Returns: true if 2nd Range lies withing first Range.

Usage for Time in Epoch Seconds. Period Intersection.

http://www.perlmonks.org/?node_id=94680

=cut

sub ranges_intersect_old
{
  my $a_start	= shift;
  my $a_end	= shift;

  my $bd_start	= shift;
  my $bd_end	= shift;


  my $intersection = 0;

  if($bd_start > $a_start && $bd_start < $a_end)
  {
    $intersection = 1;
  }
  elsif($bd_end > $a_start && $bd_end < $a_end)
  {
    $intersection = 1;
  }

  return $intersection;

}

=head2 range_date_start

Returns: Tomorrow YYYY-MM-DD to Two Years(YYYY-MM-DD)

Usage: To be used for Any Start_from Field

=cut

sub range_date_start
{

  my $today = today;

  my $tomorrow = add_days($today,1);
  my $two_years_from_today = add_days($today,732);

  return ($tomorrow,$two_years_from_today);
}

=head2 range_date_end

Returns: Day after Tomorrow( YYYY-MM-DD) to Three Years(YYYY-MM-DD)

Usage: To be used for any End_till field

=cut

sub range_date_end
{

  my $today = today;

  my $day_after_tomorrow	= add_days($today,2);
  my $three_years_from_today	= add_days($today,1096);

  return ($day_after_tomorrow,$three_years_from_today);
}

=head2 range_yyyy_mm

Creates An Array of Year and Month

Used in Drop Down box for Dates.

=cut

sub range_yyyy_mm
{
  my $begin	= shift;#yyyy-mm-dd
  my $end	= shift;#yyyy-mm-dd
  my $selected	= shift;#yyyy-mm-dd

  my ($yyyy_a,$mm_a,$dd_a) = split(/-/,$begin);
  my ($yyyy_b,$mm_b,$dd_b) = split(/-/,$end);
  my ($yyyy_s,$mm_s,$dd_s) = split(/-/,$selected);

  my (@y ,@m,@d);

  my $str_selected = "selected='selected'";

  if (!$selected)
  {
    push(@y,{value=>'YYYY',	$str_selected});
    push(@m,{value=>'MM',	$str_selected});
    push(@d,{value=>'DD',	$str_selected});
  }

  ##Selected;
  foreach my $iy ($yyyy_a..$yyyy_b)
  {

    if($iy == $yyyy_s)
    {
      my $y_s = $str_selected ;
      push(@y,{value=>$iy,selected=> $y_s});
    }
    else
    {
      push(@y,{value=>$iy});
    }
  }

  foreach my $im (1..12)
  {

    $im = "0$im" if($im < 10);
    if($im == $mm_s)
    {
      my $m_s = $str_selected ;
      push(@m,{value=>$im,selected=> $m_s});
    }
    else
    {
      push(@m,{value=>$im});
    }

  }

  foreach my $id (1..31)
  {
    $id = "0$id" if($id < 10);
    if($id == $dd_s)
    {
      my $d_s = $str_selected;
      push(@d,{value=>$id,selected=> $d_s});
    }
    else
    {
      push(@d,{value=>$id});
    }

  }


  return (\@y,\@m,\@d);

}

=head2 end_of_the_day(date)

Input: Date (yyyy-mm-dd)

Output: DateTime (yyyy-mo-dd hh:mn:ss)

=cut

sub end_of_the_day
{
  my $date = shift;

  my $fn = "C/utils/end_of_the_day";
  $date = valid_date($date);
  #print "$fn Date:$date  \n";

  my $end_time = "23:59:59";
  my $value = "$date $end_time";

  return $value;

}

=head2 start_of_the_day(date)

Input: Date (yyyy-mm-dd)

Output: DateTime (yyyy-mo-dd hh:mn:ss)

=cut

sub start_of_the_day
{
  my $date = shift;

  $date = valid_date($date);

  my $start_time = "00:00:00";
  my $value = "$date $start_time";

  return $value;

}


=back

=head1 USER DISPLAY UTILITIES

=over

=item B<display_error( $context, $str... )>

Displays one or more HTML strings in the error portion of the page.
Automatically separates multiple strings with <P>.

=cut
# Display error in page
sub display_error
{
  my
    $c = shift;
  foreach my $s( @_ )
  {
    $c->stash->{taipan}->{error} .= $s."<P>\n";
  }
}

=item B<display_message( $context, $str... )>

Displays one or more HTML strings in the message portion of the page.
Automatically separates multiple strings with <P>.

=cut
# Display message in page
sub display_message
{
  my
    $c = shift;
  foreach my $s( @_ )
  {
    $c->stash->{taipan}->{message} .= $s."<P>\n";
  }
}


=head1 LOG ERRORS

=head2 push_errors(\@list,$error_code,$error_msg,$fn)

Arguments: Array Ref,Integer:Error Code,String: Error Message,String:Fn

Returns: Array Ref

=cut 

sub push_errors
{
  my $arr_errors = shift;
  my $error_code = shift;
  my $error_msg  = shift;
  my $error_fn	 = shift;

  my $datetime = time;
  my $he;
  $he->{error}		= $error_code;
  $he->{message}	= $error_msg;
  $he->{function}	= $error_fn if($error_fn);
  $he->{time}		= $datetime;

  push(@$arr_errors,$he);
  return $arr_errors;

}

=head2 print_errors

Input: Array Ref

OutPut: Print Error in Console from Array Ref.

=cut

sub print_errors
{
  my $arr_errors = shift;

  my $fn = "U/print_errors";
  #print "$fn Begin: XXXX arr_errors  \n";

  foreach my $he(@$arr_errors)
  {
    my $error_code	= $he->{error};
    my $error_msg	= $he->{message};
    my $fn		= $he->{function};
    my $datetime	= $he->{time};

    ##Do Not comment this, This prints to the log
    print " $datetime ERROR:$error_code $error_msg $fn \n";
  }

}

=back

=over

=head1 Filter Utilities

=over

=item B<unxss( $str )>

Replace any shell/SQL metacharacters in $str with their safe URL-ised
versions (' to %27, etc.).  This is for preventing Cross-Site
Scripting (XSS) attacks.

Note:

a. Remove all leading and trailing whitespace.

b, Allows hyphen,Underscore,space in middle.

=cut
# Make XSS characters safe
sub unxss
{
  my
    $str = shift;

#Remove the leading space
  if( defined($str) )
  {
    $str =~ s/^\s*//;
    $str =~ s/\s*$//;
  }

#
#http://www.perl.com/pub//2002/02/20/css.html
#this is new, Get only Alphabets, or numbers
  $str =~ s/[^A-Za-z0-9\- \_]*//g;

  #$str = HTML::TagFilter->new->filter($str);
  $str = HTML::Entities::encode($str);
  return $str ;
}


=item B<unxss_an( $str )>

Unxss but only alpha/numeric

Returns: only alphabet and numeric characters.

=cut

sub unxss_an
{
  my
    $str = shift;

  #Remove the leading space
  if( defined($str) )
  {
    $str =~ s/^\s*//;
    $str =~ s/\s*$//;
  }

  $str =~ s/[^A-Za-z0-9]*//g;
  $str = HTML::Entities::encode($str);

  return( $str );
}

=head2 unxss_pk

All whitespace is removed(leading,or in the middle), only alphabet or number is allowed.
This can be used a Primary Key (safer).

=cut

sub unxss_pk
{
	my $str = shift;

	my $val = unxss_an($str);
	$val =~ s/\s+//g;

	return $val;

}

=item B<xnatural( $str )>

Argument: Str

Returns: True if Str is natural number.

N = {0, 1, 2, 3, ...}

A natural number is a number that occurs commonly and obviously in
nature. As such, it is a whole, non-negative number.

=cut

sub xnatural
{
  my $str = shift;

  if ($str =~ /^\d+$/)
  {
    return $str;
  }

  return undef;
}

=item B<xfloat( $str )>

Argument: Str

Returns: True if Str is float (Integer, -,+,0.1)

Perl Cookbook

=cut

sub xfloat
{
  my $str = shift;

  if ( $str =~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/)
  {
    return $str;
  }

  return undef;
}

=item B<valid_int($string)>

("0.01", "02", "3","+4","-1","a","b","A","-")

Only second and third are integer


=cut

sub valid_int
{
  my $str = shift;

  return ($str =~ m/^\d+$/);

}


=item B<valid_email( $str )>

Arguments: String

Returns: only alphabet and numeric characters.

=cut

sub valid_email
{
  my $str = shift;

  my $address = Email::Valid->address($str);

  if ($address)
  {
    return $address;
  }

  #print ($address ? 'yes' : 'no');
  return undef;

}

=head2 valid_ctype(in_type,in_value)

Returns: Value if in_value is type of in_type. Else Null

in_type:[time,date,boolean,email,float,natural,string]



=cut

sub valid_ctype
{
  my $c_type	=	shift;
  my $c_value	=	shift;

  $c_value = trim($c_value);
  $c_type  = trim($c_type);

  if (!$c_value || !$c_type)
  {
    return undef;
  }

  my $x_value;

  if ($c_type		eq 'time')
  {
    my $x_12;
    ($x_12,$x_value) = valid_time($c_value);
  }
  elsif ($c_type	eq 'date')
  {
    $x_value = valid_date($c_value);
  }
  elsif ($c_type	eq 'boolean')
  {
    if ($c_value eq 't' || $c_value eq 'f' || $c_value == 1 || $c_value == 0)
    {
      $x_value = $c_value;
    }
  }
  elsif ($c_type	eq 'email')
  {
    $x_value  = valid_email($c_value);
  }
  elsif ($c_type	eq 'float')
  {
    $x_value = xfloat($c_value);
  }
  elsif ($c_type	eq 'natural')
  {
    $x_value = xnatural($c_value);
  }
  elsif ($c_type	eq 'string')
  {
    $x_value = $c_value;
  }

  return $x_value;

}


=head2 valid_boolean(input)

Returns: a string of t/f. Else Undef.

Example:

("0.01", "02","3","+4","-1","a","b","A","-",
"f","t","on","off","F","T","true","false","FALSE")

Only from above: 02,3,f,t,F,T,true,false,False Return Boolean values.

=cut

sub valid_boolean
{
  my $in_val = shift;

  my $is_int = valid_int($in_val);
  my $value;

  if($is_int)
  {
    if ($in_val > 0)
    {
      $value = 't';
    }
    else
    {
      $value = 'f';
    }
  }
  else
  {
    $in_val = lc($in_val);
    if ($in_val eq 't'||$in_val eq 'true'||$in_val eq 'on')
    {
      $value = 't';
    }
    elsif($in_val eq 'f'||$in_val eq 'false'||$in_val eq 'off')
    {
      $value = 'f';
    }

  }

  return $value;

}


=head1 Date Search for DBIC.

=item B<<< date_search_hashref( $date ) >>>

Return a DBIx::Class::ResultSet->search compatible hashref for $date,
which may be a single date string or an arrayref [start, end].

=cut
# Make a date search hashref
sub date_search_hashref
{
  my
    $date = shift;
  my
    $date1;
  my
    $date2;
  #
  # date=>[$start, $end]
  if ( ref($date) eq 'ARRAY' )
  {
    $date1 = chomp_date($date->[0]);
    $date2 = add_days(chomp_date($date->[1]), 1);
  }
  #
  # date=>$date
  else
  {
    $date1 = chomp_date($date);
    $date2 = add_days($date1, 1);
  }
  return( {'>=', $date1, '<', $date2} );
}

=back

=head1 CONFIGURATION

These methods let you access application configuration values easily.

=over

=item B<round( $value )>

Round the value (upto .50 rounds down, .51 and greater rounds up) and
return the result.  Handles negative values.

=cut
# Round a number
sub round
{
  my
    $value = shift;
  my
    $sign = $value < 0 ? -1 : 1;
  $value = abs($value);
  my
    $int_value = int($value);
  my
    $frac_value = $value - $int_value;
  if( $frac_value > 0.50 )
  {
    return( $sign * ($int_value + 1) );
  }
  else
  {
    return( $sign * $int_value );
  }
}

=item B<<< decimal_fmt( $amount [, $decimals] ) >>>

Return string with $decimal decimal places (or 2 by default) in
$amount.

=cut
# Format with 2 (or other) decimal places
sub decimal_fmt
{
  my
    $amount = shift;
  my
    $decimals = shift;
  $decimals = 2
    unless defined($decimals);
  my
    $fmtstr = "%.${decimals}f";
  return( sprintf($fmtstr, $amount) );
}





=back

=head1 USER UTILITIES

=over

=item B<user_login( $context )>

Return the login field of the currently-selected user.

=cut
# Login ID
sub user_login
{
  my $c = shift;

  my $userid;

  if ($c->user_exists)
  {
    $userid = $c->user->get('login')||$c->user->get('userid');
  }

  return $userid;
}

=item B<user( $context )>

Return the Class::AppUser object corresponding to the currently
logged-in user, or undef if the user isn't logged in.

=cut
# Current user object
sub user
{
  my  $c = shift;
  my  $o_appuser = Class::Appuser->new($c, user_login($c));

  return( $o_appuser );

}

=item B<muser( $context )>

Return the Class::AppUser object corresponding to the currently
selected effective user for this session.  Return the currently
logged-in user if no effective user has been selected.

=cut
# Get effective user
sub muser
{
  my
    $c = shift;
  my
    $euserid = $c->session->{__effective_userid};
  return( user($c) )
    unless $euserid;
  my
    $rec = Class::Appuser->new($c, $euserid);
  return( $rec );
}

=item B<set_muser( $context [, $userid] )>

Set the effective user ID for this session to the provided $userid,
which may be a Class::AppUser object or a user ID string.  Delete
the effective user ID for this session if $userid is empty.

Return the Class::AppUser object corresponding to selected effective
user ID, or the currently logged-in user in case $userid is empty.

=cut
# Set effective user ID
sub set_muser
{
  my
    $c = shift;
  my
    $userrec = shift;
  my
    $userid = ref($userrec) ?$userrec->login :$userrec;
  if( $userid )
  {
    $c->session->{__effective_userid} = $userid;
    return( euser($c) );
  }
  else
  {
    delete($c->session->{__effective_userid});
    return( user($c) );
  }
}

=item B<is_muser( $context )>

Return 1 if the user has selected an effective user ID, 0 otherwise.

=cut
# Is effective user selected?
sub is_euser
{
  my
    $c = shift;
  return( $c->session->{__effective_userid} ?1 :0 );
}


=item B<<< check_password_strength( $password ) >>>

Check the strength of the password $password using Crypt::Cracklib.

Return undef if the password is acceptable.  Return a string
describing the weakness if the password is not strong enough.

Note that this method returns undef on success.

=cut
# Check password strength
sub check_password_strength
{
  my
    $passwd = shift;
#  my  $ret = fascist_check($passwd);
#  return( $ret eq 'ok' ?undef :$ret );

#Using Data::Password
  my $ret = IsBadPassword($passwd);
  if($ret)
  {
    return $ret;
  }
  else
  {
    return undef;
  }

}

=item B<<< generate_password( [$length] ) >>>

Generate a reasonable strong random password of $length characters.
$length defaults to 8.

=cut
# Generate random password
sub generate_password
{
  my
    $length = shift || 8;
  my
    @chars = qw/A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d
		e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7
		8 9 ! @ $ % ^ & * ( ) ' " ; : [ ] { } | = + . < > ?/;
  my
    $password = '';
  foreach my $i(1..$length)
  {
    my
      $rand = int(rand($#chars));
    $password .= $chars[$rand];
  }
  return( $password );
}


=item B<<< get_recaptcha(  ) >>>

Get HTML to display a captcha on a page.

=cut
# Get reCAPTCHA HTML
sub get_recaptcha
{
  my
    $pubkey = config(qw/internet captcha recaptcha-public-key/);
  my
    $theme = config(qw/internet captcha recaptcha-theme/);
  my
    $captcha = Captcha::reCAPTCHA->new;
  my
    $captcha_text = '';
  $captcha_text .= $captcha->get_options_setter({theme=>$theme});
  $captcha_text .= $captcha->get_html($pubkey);
  return( $captcha_text );
}

=item B<<< validate_recaptcha( $ip, $challenge, $response )
>>>

Return 0 if the reCAPTCHA response is valid, the error text otherwise.

=cut
# Validate reCAPTCHA response
sub validate_recaptcha
{
  my $ip = shift;
  my $challenge = shift;
  my $response = shift;

  my $privkey = config(qw/internet captcha recaptcha-private-key/);
  my $captcha = Captcha::reCAPTCHA->new;
  my $result = $captcha->check_answer($privkey, $ip, $challenge, $response);
  if( $result->{is_valid} )
  {
    return( 0 );
  }
  else
  {
    return( $result->{error} );
  }
}

=item B<selected_language( $context [, $language] )>

Set the language explicitely selected by the user in the session if
$language is provided.

Return the currently selected language.

=cut
# Select user-selected language in session
sub selected_language
{
  my $c		= shift;
  my $language	= shift;

  my $default_language = 'en';

#Set multilingual here
  my $multilingual = 1;

  if ($multilingual)
  {
    $c->session->{mlanguage_type} = $language
      if $language;
  }
  else
  {
    $c->session->{mlanguage_type} = $default_language;
  }

  return( $c->session->{mlanguage_type});

}


=back

=head1 GENERAL UTILITIES

=over

=item B<arg( [$n], $name, @_ )>

Extract a given argument from the arguments passed to a method.
Arguments may be passed as a list, or as a hashref.  Assume that if
there's a single argument of ref HASH it's a hashref, otherwise it's a
list.

If $n is specified it specifies the n-eth argument in the list format.
n starts from 0.

Return the corresponding argument.

=cut
sub arg
{
  my
    $n = shift;
  my
    $name;
  if( $n =~ /^\d+$/ )
  {
    $name = shift;
  }
  else
  {
    $name = $n;
    undef($n);
  }
  my
    @remaining = @_;
  my
    $hashtype = 0;
  my
    %hash;
  if( $#remaining == 0 && ref($remaining[0]) eq 'HASH' )
  {
    $hashtype = 1;
    %hash = %{$remaining[0]};
  }
  if( $hashtype )
  {
    return( $hash{$name} );
  }
  else
  {
    return( defined($n) ?$remaining[$n] :undef );
  }
}


=head1 Input/Output functions

=head2  makeparm () Private

Generic function for accepting @_ from a request like
/class/method/par1=foo/par2=bar  and change it into a hashref like ->
{par1} = 'foo', etc.

=cut

sub makeparm
{
  my $hashref = {};
  foreach (@_)
  {
    my ( $par, $value ) = split( /=/, $_, 2 );
    $hashref->{$par} = $value;
  }
return ($hashref);
}


=back

=head1 MISCELLANEOUS

=over

=item B<maphash($hash)>

Return a string containing the sorted key/values of $hash.  $hash may
be a hash or a hashref.

=cut
# Stringify hash
sub maphash
{
  my
    %hash = ref($_[0]) ? %{$_[0]} :@_;
  map{$hash{$_}='<undef>' if !defined($hash{$_})} keys(%hash); 
  return(join(', ', map{sprintf "{%s=>'%s'}", 
			  $_, $hash{$_}}sort(keys(%hash))) );
}



=item B<<< myname >>>

Return the current module and function name as a string

=cut
# Get module and function name
sub myname
{
  return( (caller(1))[3] );
}


=head1 Array Operartions

=head2 uniquearray(\@array)

This Fn returns an array of unqiue values.

=cut

sub uniquearray 
{
  my $input = shift;
  my @unique;
  my $item;
  my %checkseen = ();
  foreach $item (@$input)
  {
    $item = trim($item);
    $checkseen{$item}++;

  }
  @unique = keys %checkseen;

  ## print "General/uniquearray @unique : $#unique");
  return @unique;

}

=head2 commify ( @array||$var )

Handles Variable or Array.

=cut

sub commify
{
  my $in	= shift;


  if(ref($in) eq 'ARRAY')
  {
    my $series = commify_series(@$in);
    return $series;

  }
  else
  {
    return $in;
  }



}

=head2 commify_series ( @array )

Comify an array, Perl cookbook Page 113

=cut

sub commify_series
{
      ( @_ == 0 ) ? ''
    : ( @_ == 1 ) ? $_[0]
    : ( @_ == 2 ) ? join( " and ", @_ )
    :               join( ", ", @_[ 0 .. ( $#_ - 2 ) ], "$_[-2] and $_[-1]." );
}



=head2 sort_array(\@array,[$reverse_sort])

Argument: Array Reference, optional: If Sorting is Reverse

Returns: Array Reference

=cut

sub sort_array 
{
  my $input   = shift;
  my $reverse = shift;
  my @sorted;

  my $m = "U/sort_array";
#  print "$m";

  if ($reverse)
  {
    @sorted = reverse sort { $a cmp $b } @$input;
  }
  else
  {
    @sorted = sort { $a cmp $b } @$input;
  }

  return \@sorted;

}


=head2 intersection(\@A,\@B)

This Fn finds element which are in both arrays only.
Intersection of two arrays.

Arguments: Array Ref, Array Ref

Returns: Array Ref

=cut

sub intersection 
{
  my $a     = shift;
  my $b     = shift;

  my (@one,@two) = ();

#  @one = @$a;
#  @two = @$b;

  foreach (@$a)
  {
    my $e = $_;
    $e = trim($e);
    unshift(@one,$e);
#    print "intersect Addinging in A: @one";
  }
  foreach (@$b)
  {
    my $f = $_;
    $f = trim($f);
    push(@two,$f);
#    print "intersect Adding in B: @two";
  }

  my @isect =();
  my %original = ();

  #print "intersect A: @one";
  #print "intersect B: @two";

  map {$original{$_} = 1}  @one;
  @isect = grep {$original{$_}} @two;

  #  print "C/U/intersected : @isect ";
  return \@isect;

}


=head2 aonly(\@a,\@b)

This Fn finds element which are in first array only.

Recipe from Perl Cookbook Pg-126,4.8,Finding element in only one
array but not another.Recipe 1

Arguments: Array Ref,Array Ref

Returns: Array Ref

=cut

sub aonly
{
  my $a = shift;
  my $b = shift;

  my $m = "U/aonly";

  my %seen;

  @seen{@$a} = ();

  delete @seen{@$b};

  my @aonly = keys %seen;

  ##print "aonly \@aonly :@aonly";

  return \@aonly;

}

=head2 str_in_array(\@listx,$xstring [,is_ignore_case])

Arguments: Array Ref, String, Boolean(ignore_case)

Returns: the String IF in Array.

=cut

sub str_in_array
{
  my $baray	=	shift;
  my $xstr	=	shift;
  my $ignore_case = shift;

  $xstr = trim($xstr);

  my $ignore_str;

  my @uniqx = uniquearray($baray);
  if (defined($ignore_case))
  {
    @uniqx = map { lc } @uniqx;
    $xstr = lc($xstr);
    ##print "Making Lower Case \n";
  }

  #my ($index) = grep { $uniqx[$_] eq $xstr } (0 .. @uniqx-1);
  #return $index;


  my $value;
  my %days = map { $_ => 1 } @uniqx;
  if( $days{$xstr} )
  {
    $value = $xstr;
  }

  ##UnDefine Temp Array and Hash.
  {
    %days	= ();
    @uniqx	= ();
  }

  return $value;
}

=head2 get_array_from_argument ($string)

Argument: String separated by comma.

Returns: Array Ref

Each Argument goes through unxss

=cut

sub get_array_from_argument
{
  my $input_arg	= shift;

  my $m="C/U/get_array_from_argument";
  my @t_input_arg;

  if (ref ($input_arg) )
  {
#   print "$m IS an ARRAY:$input_arg ";
    foreach my $color (@$input_arg)
    {
#     print "$m foreach:$color";
      $color = unxss($color);
      push(@t_input_arg,$color);
    }

  }
  else
  {
#   print "$m IS NOT an ARRAY: $input_arg";
    $input_arg = unxss($input_arg);
    push(@t_input_arg,$input_arg);
  }

#  print "$m output ARR:@t_input_arg";

  return \@t_input_arg;

}


=head2 get_keyval_from_arrayofhash($c,$key,\@arr_of_hash)

Return array of values for key.

=cut

sub get_keyval_from_arrayofhash
{
  my $key		= shift;
  my $arr_of_hash	= shift;

  my $f = "U/get_keyval_from_arrayofhash";

  my @list;

  foreach my $i (@$arr_of_hash)
  {
    my $val = $i->{$key};
#    print "$f VAL($key):$val";
    push (@list,$val);
  }

#  print "$f LIST: @list";
  return @list;

}

=head2 get_keyval_from_aparams($c, $aparams, $string)

$aparams is $c->request->parameters;
$string is the string with multiple values in array.

Catalyst parameters suck and hack to handle
http://bulknews.typepad.com/blog/2009/12/perl-why-parameters-sucks-and-what-we-can-do.html


$query might become ARRAY(0xabcdef) if there are multiple query=
parameters in the query.

@names line might cause Can't use string as an ARRAY ref error if
there's only one (or zero) name parameter. This causes horrible
issues when using standard HTML elements like option
or checkbox forms, or tools like jQuery's serialize().


=cut

sub get_values_from_akey_from_aparams
{
  my $aparams	= shift;
  my $string	= shift;

  my $m = "U/get_values_from_akey_from_aparams";

  my @list;
  while ( my ($key, $value) = each(%$aparams) )
  {
    #	 print "$m ::In Hash: KEY:$key, VAL:$value";
    if ( $value && $key =~ $string && $value ne $string )
    {
      #	   print "$m SEL: $value";
      push(@list,$value);
    }
  }
#  print "$m ::$string: @list";

  return @list;

}


=head2 trim(@string)

This Fn removes the trailing or leading whitespace from a string.
Input is a string or an array.
PErl cookbook Recipe 1.19,Pg-43

=cut

sub trim 
{
  my @out = shift;

  for (@out)
  {
    s/^\s+//;			#trim left
    s/\s+$//;			#trim right
  }

  return @out == 1
    ? $out[0]			#only one to return
      : @out;			# or many

}


=head2 int_or_string(input)

Returns: (int,string)

=cut

sub int_or_string
{
  my $input = shift;

  my ($is_int,$is_string);
  if ($input =~ /^[0-9]+$/)
  {
	$is_int = $input;	
  }
  else
  {	
	$is_string = $input;
  }

  return ($is_int,$is_string);	

}

=head1 CACHE

=over

=head2 set_cache

=cut

sub set_cache
{
  my $c		= shift;
  my $in_key	= shift;
  my $in_value	= shift;
  my $expires	= shift;

  my $cache =$c->cache;
  $cache->set( $in_key, $in_value, $expires );

  return ;
}

=head2 get_cache

=cut

sub get_cache
{
  my $c		= shift;
  my $in_key	= shift;

  my $cache =$c->cache;
  my $val = $cache->get( $in_key);

  return $val;
}


=head1 CONFIGURATION

These methods let you access application configuration values easily.

=over

=head2 <config($par1, $par2, ...)>

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



=head2 get_random_string

Returns a random string.

=cut

sub get_random_string
{
  my $m = "U/get_random_string";

  my $random_alpha =
     String::Random::random_string('.'x128) ;
  my $random_beta = rand();
#  $c->log->info("$m Alpha: $random_alpha");
#  $c->log->info("$m Beta: $random_beta");

  my $random	= $random_alpha xor $random_beta;
  $random	= unxss($random);


  return $random;

}

=head2 extract_digits($string)

Extract First String of Digits from a String.

    abc23d4 => 23

=cut

sub extract_digits
{
  my $str	=	shift;

  my ( $xkey ) = $str =~ /(\d+)/;

  return $xkey;

}

=head2 get_redis

Returns the Redis Object. 

This Fn recovers from dis-connections.

=cut

sub get_redis
{

  my $fn = "U/get_redis";

  my $host	= config(qw/Database redis server/);
  my $port	= config(qw/Database redis port/);
  my $password	= config(qw/Database redis password/);
  my $debug	= config(qw/Database redis debug/);


  my $error;
  my @errors;
  my $o_redis;


  try  {

    #print "$fn Get Redis Local \n";
    $o_redis = Redis->new
      (
       server		=> "$host:$port",
       #debug		=> $debug,
       ##password	=> $password,
       reconnect	=> 10, ##Seconds
       every		=> 100,##MS

       cnx_timeout	=> 20,##Seconds

      );
    #print "$fn Redis:$o_redis \n";
  }
    catch($error)
    {
      push_errors(\@errors,3110222,$error) if($error);
    };

  if (@errors)
  {
    print_errors(\@errors);
  }


  return $o_redis;

}


=head2 redis_save_hash_field($o_Redis,Redis_key,Field,Value)

Argument: Redis Key, Field , Value

Return: (saved,$key_deleted,err_msg)

=cut

sub redis_save_hash_field
{
  my $o_redis	=	shift;
  my $key	=	shift;
  my $field	=	shift;
  my $value	=	shift;

  my ($success,$delkey,$err_msg);
  try
  {
    if (defined($value))
    {
      $success = $o_redis->hset($key,$field,$value);
    }
    else
    {
      $delkey = $o_redis->hdel($key,$field);
    }
  }
    catch($err_msg)
    {
      my $msg = $err_msg;
    }

  return ($success,$delkey,$err_msg);


}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the AGPLv3. copyright Tirveni Yadav <tirveni@udyansh.org>


=back

=cut

1;
