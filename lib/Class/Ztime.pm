#!/usr/bin/perl -w
#
# Class::Ztime
#
# 2017-05-28
#
package Class::Ztime;

use Moose;
use namespace::autoclean;

use TryCatch;
use DateTime;

use Class::Utils qw(trim unxss valid_date time_in_range chomp_date chomp_time);
use Number::Closest;


=pod

=head1 NAME

Class::Ztime - Utilities for handling Date/Time with zone

=head1 SYNOPSIS

    use Class::Ztime;
    $o_ztime	= Class::Ztime->new(time_zone=>'UTC');
    $zone       = $o_msg->time_zone;

Default Time_Zone is UTC

=cut

has 'time_zone' =>
  (
   is		=> 'ro',
   isa		=> 'Str',
   default	=> 'UTC',
   required	=> 1
  );


=head1 ADMINISTRIVIA

=over


=head1 ACCESSORS

=head2 now

Returns: now

=cut

sub now
{
  my $self  = shift;

  my $time_zone = $self->time_zone ;

  my $o_dt      = DateTime->now(time_zone => $time_zone);

  my $now   = $o_dt->hms;

  return $now;
}


=head2 today

Return the Current Date and current time as Yyyy-mm-dd HH:MM:SS+0000.

=cut

sub today
{
  my $self = shift;

  my $time_zone = $self->time_zone ;

  my $o_dt      = DateTime->now(time_zone => $time_zone);

  my $today = $o_dt->ymd;

  return $today;
}


=head2 today_now

Return the Current Date and current time as Yyyy-mm-dd HH:MM:SS

=cut

sub today_now
{
  my $self = shift;

  my $time_zone = $self->time_zone;
  my $o_dt      = DateTime->now(time_zone => $time_zone);

  my $today = $o_dt->ymd;
  my $now   = $o_dt->hms;
  my $today_now = "$today $now";

  return $today_now;
}

=head2 start_of_the_day_in_utc($date)

Returns: DateTime (yyyy-MM-dd HH:mm:ss +0000), DateTime (HTTP-Date Format)

Both the Dates are in UTC

=cut

sub start_of_the_day_in_utc
{
  my $self	= shift;
  my $date	= shift;

  my $fn = "C/ztime/start_of_the_day";
  $date = Class::Utils::valid_date($date);

  my $start_time = "00:00:00";
  my $in_date_time = "$date $start_time";

  my $out_tz = 'UTC';
  my $in_tz = $self->time_zone;

  my $utc_date_time;
  ($utc_date_time,$out_tz) = 
    Class::Ztime::dt_tz_convert($out_tz,$in_date_time,$in_tz);
  my $http_date = http_date($utc_date_time);

  #print "$fn IN: $in_date_time ($in_tz), OUT:$utc_date_time \n";

  return ($utc_date_time,$http_date);
}


=head2 end_of_the_day_in_utc($date)

Returns: DateTime (yyyy-MM-dd HH:mm:ss +0000), DateTime (HTTP-Date Format)

Both the Dates are in UTC

=cut

sub end_of_the_day_in_utc
{
  my $self	= shift;
  my $date	= shift;

  my $fn = "C/ztime/end_of_the_day";
  $date = Class::Utils::valid_date($date);

  my $end_time = "23:59:59";
  my $in_date_time = "$date $end_time";

  my $out_tz = 'UTC';
  my $in_tz = $self->time_zone;

  my $utc_date_time;
  ($utc_date_time,$out_tz) = 
    Class::Ztime::dt_tz_convert($out_tz,$in_date_time,$in_tz);
  my $http_date = http_date($utc_date_time);

  #print "$fn IN: $in_date_time ($in_tz), OUT:$utc_date_time \n";

  return ($utc_date_time,$http_date);
}

=head2 valid_dt_tz($in_datetime_tz)

Arguments: In DateTime:

Returns: ($o_dt,$str_datetime_tz)

=cut

sub valid_dt_tz
{
  my $in_datetime = shift;

  my $fn = "C/Ztime/valid_dt_tz";
  my ($o_dt,$out_date_time);

  my $default_tz = 'floating';
  my ($yyyy,$mon,$dd,$hh,$min,$ss, $in_tz) = 
    Class::Utils::datetime_split($in_datetime);

  if (!$in_tz)
  {
    $in_tz = $default_tz;
  }

  {
    $hh = $hh || 00;
    $hh = int($hh);

    $min = $min || 00;
    $min = int($min);

    $ss = $ss || 00;
    $ss = int($ss);
  }

  try  {

    $o_dt = DateTime->new
      (
       year		=> $yyyy,
       month		=> $mon,
       day		=> $dd,
       hour		=> $hh,
       minute		=> $min,
       second		=> $ss,
       time_zone	=> $default_tz,
      );

    if ($o_dt)
    {
      $out_date_time     =  $o_dt->strftime('%Y-%m-%d %T %z');
    }

  };

  ##print "$fn $in_datetime/$out_date_time  \n";
  return ($o_dt,$out_date_time);

}

=head2 date_formatter(in_date[,format])

Default Format: YYYY-MMM-DD

Returns: (DateTime Object,yyyy-mm-dd,day_of_week,formatted_date)

=cut

sub date_formatter
{
  my $in_date	=	shift;
  my $in_format =	shift;

  my $fn = "C/ztime/date_formatter";
  #print "$fn fmt:$in_format \n";

  ##--A. VAlidity
  my ($valid_date,$valid_format);
  $valid_date	= valid_date($in_date);
  $in_format	= trim($in_format);

  if (   $in_format eq 'YYYY-MM-DD'
      || $in_format eq 'DD-MMM-YYYY'
      || $in_format eq 'YYYY-MMM-DD'
      || $in_format eq 'MMM-DD-YYYY'
     )
  {
    $valid_format = $in_format;
  }
  else
  {
    $valid_format = "YYYY-MMM-DD";
  }
  #print "$fn fmt:$valid_format \n";

  ##-- B. Get Year,Mm,dd
  my ($yyyy, $mm, $dd) = split(/-/,$valid_date);

  ##-- C. DateTime
  my $o_dt = DateTime->new
    (
     year       => $yyyy,
     month      => $mm,
     day	=> $dd,
    );

  my $date_x;

  ##-- Get WeekDay, MonthAbbr.
  my $weekday_name = $o_dt->day_abbr;
  my $month_name   = $o_dt->month_abbr;

  ##-- Set Date
  if ($valid_format eq 'YYYY-MMM-DD')
  {
    $date_x = "$yyyy-$month_name-$dd";
  }
  elsif ($valid_format eq 'DD-MMM-YYYY')
  {
    $date_x = "$dd-$month_name-$yyyy";
  }
  elsif ($valid_format eq 'MMM-DD-YYYY')
  {
    $date_x = "$month_name-$dd-$yyyy";
  }
  else
  {
    $date_x = $valid_date;##ISO
  }
  print "$fn WeekDay:$weekday_name \n";

  ($o_dt,$in_date,$weekday_name,$date_x);

}


=head2 http_date(utc_date_time)

Input: YYYY-mm-DD HH:MM:SS +0000

Output: Date in HTTP-Date format

Format: Day_abbrv, Date Month_abbrv Year HH:MM:SS GMT

Example: "Sat, 28 May 2016 21:59:59 GMT"

=cut

sub http_date
{
  my $utc_date_time = shift;

  my $http_date;
  my ($x_date,$x_time,$x_tz) =  split(/ /,$utc_date_time);

  my ($xy,$xm,$xd)	= split(/-/,$x_date );
  my $o_xdate		= DateTime->new(year=>$xy,month=>$xm,day=>$xd);

  my $month_name	= $o_xdate->month_abbr;
  my $day_name		= $o_xdate->day_abbr;
  $http_date = "$day_name, $xd $month_name $xy $x_time GMT";

  return $http_date;
}

=head2 dt_tz_convert($out_tz,$in_datetime[,$in_tz])

Accepts: TimeZone(Out/To), Date, TZ [In/from]

Returns: (Date in UTC TimeZone, TimeZone)

OutDate Format: %Y-%m-%d %T %z,2016-05-03 22:00:00 +0000
[This date format is acceptable in PSQL].

=cut

sub dt_tz_convert
{
  my $out_timezone = shift;
  my $in_datetime = shift;
  my $in_timezone = shift;##Storing only

  my $fn = "C/Ztime/dt_tz_convert";
  my $out_date_time;

  my ($yyyy,$mon,$dd,$hh,$min,$ss, $default_tz) = 
    Class::Utils::datetime_split($in_datetime);

  if (!$in_timezone && $default_tz)
  {
    $in_timezone = "$default_tz";
  }

  #print "$fn input: $out_timezone,$in_datetime,$in_timezone  \n";
  #print "$fn Extract: DateTime:$yyyy-$mon-$dd $hh-$min-$ss, $default_tz  \n";
  ##Hour,Min,Sec Default Values
  {
    $hh = $hh || 00;
    $hh = int($hh);

    $min = $min || 00;
    $min = int($min);

    $ss = $ss || 00;
    $ss = int($ss);
  }
  #print "$fn $yyyy/$mon/$dd $hh:$min:$ss Zone:$in_timezone \n";

  my $o_dt;

  $o_dt = DateTime->new
    (
     year       => $yyyy,
     month      => $mon,
     day        => $dd,
     hour       => $hh,
     minute     => $min,
     second     => $ss,
     time_zone  => $in_timezone,
    );

  ##Get the Date/Time
  my $str_date_time     =  $o_dt->strftime('%Y-%m-%d %T %z');

  ##Set the New TimeZone
  $o_dt->set_time_zone($out_timezone);

  $out_date_time     =  $o_dt->strftime('%Y-%m-%d %T %z');
  #print "$fn Date_Time_Zone:$out_date_time \n";

  return ($out_date_time,$out_timezone);

}

=head2 day_of_week(date )

Input: Date [format: yyyy-mm-dd]

Returns: Day of Week [Format: 1-7 (Monday is 1)]

=cut

sub day_of_week
{
  my $date = shift;

  my ($v_date,$weekday,$o_dt);

  $v_date = Class::Utils::valid_date($date)
    if($date);

  my ($year,$month,$day) = split(/-/,$v_date)
    if($v_date);

  $o_dt = DateTime->new
    (
     year       => $year,
     month      => $month,
     day	=> $day,
    ) if($year && $month && $day);

  if (defined($o_dt))
  {
    $weekday = $o_dt->day_of_week();
  }

  return $weekday;

}

=head2 week_day(in_day)

Returns: Day_name,day_of_week

day_of_week: 1 to 7. 7 is sunday. 1 is monday.

in_day: int (1 to 7), or string(Mon to Sun)

=cut

sub week_day
{
  my $in_day = shift;

  my $fn = "c/Ztime/in_day";
  #print "$fn Input $in_day \n";

  my ($day_name,$day_of_week);
  my
    @week = (qw/NONE Monday Tuesday Wednesday Thursday Friday Saturday 
		Sunday/);

  my $is_int = Class::Utils::valid_int($in_day);
  if ($is_int)
  {
    $in_day = int($in_day);
    if ($in_day > 0 && $in_day < 8)
    {
      $day_name		= $week[$in_day];
      $day_name		= $day_name;
      $day_of_week	= $in_day;
    }
    #print "$fn In: $in_day, $day_name \n";
  }
  else
  {
    my $in_name = lc(substr($in_day,0,3));

    my $count = 0;
    foreach my $wdn(@week)
    {
      my $lc_wdn = lc(substr($wdn,0,3));

      if ($lc_wdn eq $in_name)
      {
	$day_name	= $wdn;
	$day_of_week	= $count;
	last;
      }

      $count++;
    }

  }

  return ($day_name,$day_of_week);

}

=head1 TIME

Ops on Time

=head2 add_time(Date_Time, Add Time)

Arguments: Date_Time (YYYY-mm-DD HH:mm:SS),Time (HH:mm:SS)

Returns: (yyyy-mm-dd,hh:mm:ss)

This tries to keep it simple, hence without TimeZone

=cut

sub add_time
{
  my $in_datetime = shift;
  my $time_add	  = shift;

  my $fn = "C/Ztime/add_time";

  #print "$fn Input: $in_datetime \n";
  my ($y_date_time,$o_dt,$o_dt_z);
  my ($yyyy,$mon,$dd,$hh,$min,$ss, $default_tz);

  ##-- 1. Remove any Zone for Simplicity
  {
    my $y_date = chomp_date($in_datetime);
    my $y_time = chomp_time($in_datetime);
    $y_date_time = "$y_date $y_time";

    ($yyyy,$mon,$dd,$hh,$min,$ss, $default_tz) = 
      Class::Utils::datetime_split($y_date_time);
  }

  ##-- 2. Get Base DT Object
  $o_dt = DateTime->new
    (
     year       => $yyyy,
     month      => $mon,
     day	=> $dd,
     hour       => $hh,
     minute     => $min,
     second     => $ss,
     time_zone	=> 'floating',
    );

  #print "$fn Before: $o_dt \n";

  ##-- 3. Convert Add Time to Hour,Min,Sec
  my ($x_hh,$x_min,$x_ss) = split(':',$time_add);

  ##-- 4. Add X to DT: Gives DT_Z
  if ($x_hh && $x_min && $x_min && $o_dt)
  {
    $o_dt_z =
      $o_dt->add(hours =>$x_hh,minutes=>$x_min,seconds=>$x_ss);
  }

  ##-- 5. Covert Delta to: YMD,HMS,Zone
  my ($ymd,$hms,$tz_name);
  if ($o_dt_z)
  {
    $ymd = $o_dt_z->ymd;
    $hms = $o_dt_z->hms;

    #my $o_tz = $o_dt_z->time_zone();
    #$tz_name = $o_tz->name(); +0000
  }

  #print "$fn zx:$hms \n";
  #print "$fn After:$o_dt_z \n";

  return ($ymd,$hms);

}

=head2 subtract_time(Date_Time, Add Time)

Arguments: Date_Time (YYYY-mm-DD HH:mm:SS),Time (HH:mm:SS)

Returns: (yyyy-mm-dd,hh:mm:ss)

This tries to keep it simple, hence without TimeZone

=cut

sub subtract_time
{
  my $in_datetime = shift;
  my $time_minus  = shift;
  my $in_tz	  = shift;

  my $fn = "C/Ztime/add_time";
  #print "$fn Input: $in_datetime \n";
  my ($y_date_time,$o_dt,$o_dt_z);
  my ($yyyy,$mon,$dd,$hh,$min,$ss, $default_tz);

  ##-- 1. Remove any Zone for Simplicity
  {
    my $y_date = chomp_date($in_datetime);
    my $y_time = chomp_time($in_datetime);
    $y_date_time = "$y_date $y_time";

    ($yyyy,$mon,$dd,$hh,$min,$ss, $default_tz) = 
      Class::Utils::datetime_split($y_date_time);
  }


  ##-- 2
  $o_dt = DateTime->new
    (
     year       => $yyyy,
     month      => $mon,
     day	=> $dd,
     hour       => $hh,
     minute     => $min,
     second     => $ss,
     time_zone	=> 'floating',
    );

  ##-- 3. Convert Time Minus to: HH,MM,SS
  my ($x_hh,$x_min,$x_ss) = split(':',$time_minus);

  ##-- 4. Add X to DT: Gives DT_Z
  if ($o_dt && $x_hh && $x_min && $x_ss)
  {
    $o_dt_z = $o_dt->subtract(hours =>$x_hh,minutes=>$x_min,seconds=>$x_ss);
  }

  ##-- 5. GET ymd,hms,TZ
  my ($ymd,$hms,$tz_name);
  if ($o_dt_z)
  {
    $ymd = $o_dt_z->ymd;
    $hms = $o_dt_z->hms;

    #my $o_tz = $o_dt_z->time_zone();
    #$tz_name = $o_tz->name(); +0000
  }

  #print "$fn zx:$hms \n";
  #print "$fn After:$o_dt_z \n";

  return ($ymd,$hms);

}


=head2 time_ranges_intersect($a_low,$a_up,$z_low,z_up)

Returns: 1 If Intersect

=cut

sub time_ranges_intersect
{

  my $a_lower	= shift;
  my $a_upper	= shift;

  my $z_lower	= shift;
  my $z_upper	= shift;

  my $f = "Ztime/time_range_intersect";
  #print "$f $a_lower/$a_upper :: $z_lower/$z_upper \n";

  ##Check A in Z
  my ($a_lower_in,$a_upper_in);
  $a_lower_in = time_in_range($a_lower,$z_lower,$z_upper);
  $a_upper_in = time_in_range($a_upper,$z_lower,$z_upper);

  ##Reverse Also
  my ($z_lower_in,$z_upper_in);
  $z_lower_in = time_in_range($z_lower,$a_lower,$a_upper);
  $z_upper_in = time_in_range($z_upper,$a_lower,$a_upper);

  #print "$f $a_lower_in/$a_upper_in \n";
  my $intersect = 0;
  if ( ($a_lower_in  > 0)  || ($a_upper_in > 0) ||
       ($z_lower_in  > 0)  || ($z_upper_in > 0) )
  {
    $intersect = 1;
  }

  print "$f Intersect:$intersect \n";
  return $intersect;


}

=head2 closest_time($in_time,\@time)

Array @time: contains time in 24 hour format only.

Returns: the ArrayRef containing two time strings from @time which is closest
to $in_time.

=cut

sub closest_time
{
  my $in_time	=	shift;
  my $list_time =	shift;

  my $fn = "C/Ztime/closest_time";
  my $closest;

  ##A. Convert to a fresh Array and String
  my @x_slots = @$list_time;
  my $x_intime = $in_time;

  ##B. Convert string : to none, as 24 hour is ok
  ## HH:MM:ss to HHMM Format
  $x_intime = substr($x_intime,0,5); ##hh:mm:ss

  $x_intime =~ s/://g;
  s/:// for @x_slots;

  print "$fn  Time:$x_intime,  Slots:@x_slots  \n";

  ##Find
  my $finder = Number::Closest->new(number => $x_intime,
				   numbers => \@x_slots) ;
  my $a_closest = $finder->find(2); # finds closest number

  my $x_list;
  foreach my $x(@$a_closest)
  {
    ##Convert Back to HH:MM
    my $hh = substr($x,0,2);
    my $mm = substr($x,2,2);
    push(@$x_list,"$hh:$mm");
  }

  return $x_list;

}

=head2 times_increasing(a_hh:mm,z_hh:mm)

Returns 1 if Times are equal or second is higher than first

=cut

sub times_increasing
{
  my $a_time = shift;
  my $z_time = shift;

  my $fn = "C/ztime/times_increasing";
  $a_time = substr($a_time,0,5);
  $z_time = substr($z_time,0,5);

  my ($a_hh,$a_mm) = split(/:/,$a_time);
  my ($z_hh,$z_mm) = split(/:/,$z_time);
  print "$fn $a_hh:$z_mm/$z_hh:$z_mm \n";

  my $is_increasing = 0;

  if ($a_hh < $z_hh)
  {
    $is_increasing = 1;
    #print "$fn Hour is greater \n";
  }
  elsif ( ($a_hh eq $z_hh) && ($a_mm < $z_mm))
  {
    $is_increasing = 1;
    #print "$fn Hour is Same.Minutes Higher \n";
  }
  else
  {
    print "$fn ELSE Time is Past: $is_increasing \n";
  }
  print "$fn $a_hh:$z_mm/$z_hh:$z_mm/Future:$is_increasing \n";

  return $is_increasing;

}

=head2 datetime_incresing(base_date,base_now,check_date,check_now)

Return: 1 if $base_date-$base_now <= $check_date-$check_now ELSE 0

=cut

sub datetime_increasing
{
  my $base_date	= shift;
  my $base_now	= shift;
  my $check_date	= shift;
  my $check_time	= shift;

  if (!$check_time || !$check_date || !$base_date || !$base_now)
  {
    return undef;
  }

  my $fn = "C/ztime/datetime_increasing";
  my $is_future = 0;
  #print "$fn $base_date $base_now/$check_date $check_time \n";

  my ($is_date_time_past);
  {
    my $is_date_in_future = Class::Utils::dates_increasing
      ($base_date,$check_date);
    #print "$fn Date Input:$check_date $check_time \n";
    #print "$fn Base:$base_date,Future: $is_date_in_future \n";

    if ($is_date_in_future > 0)
    {
      $is_future = 1;
    }
    elsif ($base_date eq $check_date)
    {
      my $is_time_increasing;
      $is_time_increasing = Class::Ztime::times_increasing
	($base_now,$check_time);
      print "$fn Time Increasing:$is_time_increasing".
	"($base_now/$check_time) \n";
      if ($is_time_increasing > 0)
      {
	$is_future = 1;
      }
    }##-- Elsif
  }
  print "$fn Future: $is_future \n";

  return $is_future;

}

=head1 ZONE

TimeZone

=head2 valid_zone($dbic,$in_name)

Returns: row_zone if available in the db.

=cut

sub valid_zone
{
  my $dbic	= shift;
  my $in_name	= shift;

  my $table_timezones = $dbic->resultset("Zone");
  my $row_tz;

  $in_name = trim($in_name);

  if($in_name)
  {
    my $rs_timezones = $table_timezones->search
      (
       {zone_name => "$in_name", },
      );

    $row_tz = $rs_timezones->first if(defined($rs_timezones));
  }

  return $row_tz;

}

=head1 FUTURE RANGE VALIDATION

Check if Date Range can be edited or not.

#=head2 is_past_or_same($current_date,$date_x)

#Returns: true if second date is same as first_date, or before first_date.

#=cut

#sub is_past_or_same_x
#{
#  my $current_date = shift;
#  my $date_x       = shift;

#  my $fn = "C/utils/is_past_or_same";
#  if (!$current_date || !$date_x)
#  {
#    return undef;
#  }

#  my ($errors,$is_future) =
#    Class::Utils::dates_increasing($current_date,$date_x);

#  print "$fn Current:$current_date, Date:$date_x \n";

#  my $is_past_present;
#  if ($current_date eq $date_x)
#  {
#    $is_past_present = 1;
#  }
#  elsif ($is_future <= 0)
#  {
#    $is_past_present = 1;
#  }
#  else
#  {
#    $is_past_present = 0;
#  }


#  return $is_past_present;
#}


=head2 is_past_or_same($current_date,$date_x)

Returns: true if second date is same as first_date, or before first_date.

=cut

sub is_past_or_same
{
  my $current_date = shift;
  my $date_x       = shift;

  my $fn = "C/utils/is_past_or_same";
  if (!$current_date || !$date_x)
  {
    return undef;
  }

  my $current_epoch =
    Class::Utils::utc_datetime_to_epoch($current_date);
  my $x_epoch =
    Class::Utils::utc_datetime_to_epoch($date_x);

  my ($is_past_present);
  my ($errors,$is_future);
  if ($x_epoch > $current_epoch)
  {
    $is_past_present	= 0;
  }
  elsif ($x_epoch == $current_epoch)
  {
    $is_past_present	= 1;
  }
  elsif ($x_epoch < $current_epoch)
  {
    $is_past_present	= 1;
  }

  return ($is_past_present);
}

=head2 edit_future_range_x($current_date,{old_start,old_end,new_start,new_end})

Check if Range is in future.

Returns: ($is_today_in_range,$errors,$new_start,$new_end)

Check on Old Range(old_start,old_end)

IS_PAST.

       NO_CHANGE

IS_PRESENT

        NEW_END >= TODAY

IS_FUTURE

        NEW_START > TODAY

        NEW_END   > NEW_START

=cut

sub edit_future_range_x
{
  my $current_date	= shift;
  my $in_vals		= shift;

  my $fn = "C/utils/edit_future_range";

  my $case = $in_vals->{testing_case} || 1;

  my ($old_start,$old_end);
  $old_start	= $in_vals->{old_start};
  $old_end	= $in_vals->{old_end};

  my ($new_start,$new_end);
  $new_start	= $in_vals->{new_start};
  $new_end	= $in_vals->{new_end};

  print "$fn ($case) Current:$current_date.  \n";
  print "$fn ($case) Old:$old_start<>$old_end.  \n";
  print "$fn ($case) New:$new_start<>$new_end.  \n";

  my ($date_a,$date_z);


  ##-- 1. IF any of the new dates are undef, then return Old Range
 check_1:
  print "$fn 1. New Dates Validation \n";
  my ($is_past_present,$errors);
  if (!$new_start || !$new_end)
  {
    ($date_a,$date_z) = ($old_start,$old_end);
    print "$fn 1a: $date_a<=>$date_z  \n";
    return ($is_past_present,$errors,$date_a,$date_z);
    ## R_1a
  }

  my ($is_old_range_past);
  {
    $is_old_range_past = Class::Ztime::is_past_or_same
      ($current_date,$old_start);
    $in_vals->{is_old_range_past} = $is_old_range_past;
    print "$fn ($case) OLD_RANGE_PAST: $is_old_range_past \n";
  }

  ##Date Increasing is buggy

  ##-- 2. Check Ranges are Valid
  check_2:
  my ($is_range_new_past_present,$is_range_old_past_present);
  $is_range_old_past_present = Class::Ztime::is_past_or_same
    ($old_start, $old_end);
  print "$fn ($case) old Increasing: $is_range_old_past_present  \n";
  $is_range_new_past_present = Class::Ztime::is_past_or_same
    ($new_start,$new_end);
  print "$fn ($case) New Increasing: $is_range_new_past_present  \n";

  check_2a:
  print "$fn 2. Range Validation \n";

  if    ($is_range_old_past_present > 0 && ($old_start ne $old_end) )
  {
    my $msg = "Old Range is Reverse ($old_start/$old_end)";
    push(@$errors,$msg);
    print "$fn ($case) $msg \n";

    $is_past_present = $is_old_range_past;
    ($date_a,$date_z) = undef;

    print "$fn 2a: $date_a<=>$date_z  \n";
    return ($is_past_present,$errors,$date_a,$date_z);
    ##R_2a
  }
  elsif ($is_range_new_past_present > 0 && ($new_start ne $new_end))
  {
    my $msg = "New range in Reverse: ($new_start/$new_end)";
    push (@$errors,$msg);
    print "$fn ($case) $msg \n";

    ($date_a,$date_z) = undef;

    print "$fn 2b: $date_a<=>$date_z  \n";
    return ($is_past_present,$errors,$date_a,$date_z);
    ##R_2b
  }

 check_3:
  print "$fn 3. Tense Validation Start \n";
  ($is_past_present,$errors,$date_a,$date_z)
    = _edit_future($current_date,$in_vals,$case);
  ##Continue if All the five Dates are present.
  print "$fn 3. Tense Validation End \n";

  return ($is_past_present,$errors,$date_a,$date_z);

}


=head2 _edit_future($current_date,{old_start,old_end,new_start,new_end})

After all the Validation this checks Function Checks Tense.

Returns: ($is_past_present,$errors,$date_a,$date_z);

=cut

sub _edit_future
{
  my $current_date      = shift;
  my $h_in		= shift;
  my $case		= shift;

  my $old_start =  $h_in->{old_start};
  my $old_end	=  $h_in->{old_end};
  my $new_start =  $h_in->{new_start};
  my $new_end   =  $h_in->{new_end};

  my $is_old_range_past = $h_in->{is_old_range_past};

  my $fn = "c/ztime/_edit_future";
  my ($date_a,$date_z);
  my ($errors,$is_past_present);

  my ($till_new_gt_current,$till_new_same_current);
  my ($is_old_range_future,$is_old_range_present,
      $is_new_range_future,$is_new_range_past);

  {
    $is_new_range_past = Class::Ztime::is_past_or_same
      ($current_date,$new_start);
    print "$fn ($case) NEW_RANGE_PAST: $is_new_range_past \n";
  }

  {
     ($errors,$is_old_range_future) =
      Class::Utils::dates_increasing($current_date,$old_start,$old_end);

     ($errors,$is_new_range_future) =
      Class::Utils::dates_increasing($current_date,$new_start,$new_end);

     $is_old_range_present = Class::Utils::date_in_range
       ($current_date,$old_start,$old_end);
     print "$fn ($case) OLD_RANGE_PRESENT: $is_old_range_present \n";

     $till_new_gt_current =
       Class::Utils::dates_increasing($current_date,$new_end);

     if ($till_new_gt_current < 1 && ($current_date eq $new_end))
     {
       $till_new_same_current = 1;
     }
     print "$fn ($case) till_new_gt_current: $till_new_gt_current \n";
  }

  print "$fn Present: $till_new_gt_current && $is_old_range_present \n";


  if ($is_old_range_present > 0 && ($till_new_gt_current > 0))
  {
    print "$fn 3a. ($case) xOLD RANGE PRESENT: $is_old_range_present \n";
    ($date_a,$date_z) = ($old_start,$new_end);
    $is_past_present = $is_old_range_present;
    print "$fn ($case) $new_end > $current_date \n";
  }
  elsif ($is_old_range_present > 0 && ($till_new_same_current > 0))
  {
    ($date_a,$date_z) = ($old_start,$new_end); 
    $is_past_present = $is_old_range_present;
    print "$fn 3b. ($case) $new_end == $current_date \n";
  }
  elsif ($is_old_range_past == 0 && $is_new_range_past == 0)
  {
    ($date_a,$date_z) = ($new_start,$new_end);
    print "$fn 3c. ($case) $date_a,$date_z \n";
    ##Both Ranges are New: Change is allowed.
    ##-- All Future, Allow
  }
  elsif ($is_old_range_past  > 0)
  {
    ($date_a,$date_z) = ($old_start,$old_end);
    print "$fn 3d. ($case) $date_a,$date_z \n";
    ##Old Range in Past: No change.
  }
  elsif ($is_new_range_past  > 0)
  {
    ($date_a,$date_z) = ($old_start,$old_end);
    print "$fn 3e. ($case) $date_a,$date_z \n";
    ##New Range is in Past: NO CHANGE
  }

  print "$fn ($case) Values:$date_a<>$date_z.  \n";

  return ($is_past_present,$errors,$date_a,$date_z);


}

=head1 FUTURE

All epoch

=head2 get_tense($current_date,$date_x)

Returns: true if second date is same as first_date, or before
first_date. 

Returns: ($is_past,$is_present,$is_future,$is_past_present)

=cut

sub get_tense
{
  my $current_date = shift;
  my $date_x       = shift;

  my $fn = "C/utils/is_past_or_same";
  if (!$current_date || !$date_x)
  {
    return undef;
  }

  my $current_epoch =
    Class::Utils::utc_datetime_to_epoch($current_date);
  my $x_epoch =
    Class::Utils::utc_datetime_to_epoch($date_x);

  my ($is_past,$is_present,$is_future,$is_past_present) = undef;
  if ($x_epoch > $current_epoch)
  {
    $is_future = 1;
  }
  elsif ($x_epoch == $current_epoch)
  {
    $is_past_present	= 1;
    $is_present		= 1;
  }
  elsif ($x_epoch < $current_epoch)
  {
    $is_past_present = 1;
    $is_past	     = 1;
  }

  return ($is_past,$is_present,$is_future,$is_past_present);
}


=head2 edit_future_range($current_date,{old_start,old_end,new_start,new_end})

Check if Range is in future. Based on Epoch(seconds)

Returns: ($is_today_in_range,$errors,$new_start,$new_end)

Check on Old Range(old_start,old_end)

IS_PAST.

       NO_CHANGE

IS_PRESENT

        NEW_END >= TODAY

IS_FUTURE

        NEW_START > TODAY

        NEW_END   > NEW_START

=cut

sub edit_future_range
{
  my $current_date	= shift;
  my $in_vals		= shift;

  my $fn = "C/utils/edit_future_range_e";

  my $case = $in_vals->{testing_case} || 1;

  my ($old_start,$old_end);
  $old_start	= $in_vals->{old_start};
  $old_end	= $in_vals->{old_end};

  my ($new_start,$new_end);
  $new_start	= $in_vals->{new_start};
  $new_end	= $in_vals->{new_end};

  print "$fn ($case) Current:$current_date.  \n";
  print "$fn ($case) Old:$old_start<>$old_end.  \n";
  print "$fn ($case) New:$new_start<>$new_end.  \n";

  my ($is_past_present,$errors);
  my ($date_a,$date_z);


  ##-- 1. IF any of the new dates are undef, then return Old Range
 efr_1:
  #print "$fn 1. New Dates Validation \n";
  if (!$new_start || !$new_end)
  {
    ($date_a,$date_z) = ($old_start,$old_end);
    #print "$fn 1a: $date_a<=>$date_z  \n";
    return ($is_past_present,$errors,$date_a,$date_z);
    ## R_1a
  }

  ##-- Get some basic values
 efr_2:
  my ($old_start_e,$old_end_e,$new_start_e,$new_end_e,$current_e);
  my ($is_old_range_past_present);
  {
    ##---  Convert to Epochs
    ##---- All the Epochs: five of them
    $old_start_e = Class::Utils::utc_datetime_to_epoch($old_start);
    $old_end_e   = Class::Utils::utc_datetime_to_epoch($old_end);

    $new_start_e = Class::Utils::utc_datetime_to_epoch($new_start);
    $new_end_e   = Class::Utils::utc_datetime_to_epoch($new_end);

    $current_e   = Class::Utils::utc_datetime_to_epoch($current_date);

    $is_old_range_past_present = Class::Ztime::get_tense
      ($current_date,$old_start);
    $in_vals->{is_old_range_past} = $is_old_range_past_present;
    #print "$fn ($case) OLD_RANGE_PAST: $is_old_range_past_present \n";
  }

  ##-- 2. Check Ranges are Valid, Same Dates or Increasing ELSE 0
  ##-- This validation if not done here, then it messes-up 
  ## _edit_future_epoch
 efr_3:
  {

    my ($is_old_range_valid,$is_new_range_valid) = 0;
    if ($old_start_e <= $old_end_e)
    {
      $is_old_range_valid = 1;
    }
    if ($new_start_e <= $new_end_e)
    {
      $is_new_range_valid = 1;
    }

    if ($is_old_range_valid < 1 )
    {
      ##InValid Old Range: Return Undef
      my $msg = "Old Range is Reverse ($old_start/$old_end)";
      push(@$errors,$msg);
      #print "$fn ($case) $msg \n";

      $is_past_present = $is_old_range_past_present;
      ($date_a,$date_z) = undef;

      #print "$fn 2a: $date_a<=>$date_z  \n";
      return ($is_past_present,$errors,$date_a,$date_z);
      ##R_2a
    }
    elsif ($is_new_range_valid < 1)
    {
      ##InValid Old Range: Return Undef
      my $msg = "New range in Reverse: ($new_start/$new_end)";
      push (@$errors,$msg);
      #print "$fn ($case) $msg \n";

      ($date_a,$date_z) = undef;

      #print "$fn 2b: $date_a<=>$date_z  \n";
      return ($is_past_present,$errors,$date_a,$date_z);
      ##R_2b
    }

  }


 efr_4:
  {

    {
      $in_vals->{old_start_epoch} = $old_start_e;
      $in_vals->{old_end_epoch}   = $old_end_e;

      $in_vals->{new_start_epoch} = $new_start_e;
      $in_vals->{new_end_epoch}   = $new_end_e;
      $in_vals->{current_epoch}   = $current_e;

      $in_vals->{is_old_range_past} = $is_old_range_past_present;
    }

    print "$fn 4. Tense Validation Start \n";
    ($is_past_present,$errors,$date_a,$date_z)
      = _edit_future_epoch($current_date,$in_vals,$case);
    ##Continue if All the five Dates are present.
    print "$fn 4. Tense Validation End ($date_a/$date_z) \n";
  }

  ##Get new_end_in_future_present
  ##
 efr_5:


  return ($is_past_present,$errors,$date_a,$date_z);



}

=head2 _edit_future_epoch($current_date,hash_ref,case_debug)

Argument: Hash: {old_start,old_end,new_start,new_end,
old_start_epoch,old_end_epoch,new_start_epoch,new_end_epoch,current_epoch}

After all the Validation this checks Function Checks Tense.

Returns: ($is_past_present,$errors,$date_a,$date_z);

date_a,date_z: are in format yyyy-MM-dd

=cut

sub _edit_future_epoch
{
  my $current_date    = shift;
  my $h_in		= shift;
  my $case		= shift;

  my $fn = "_edit_future_epoch";
  my $errors;

  my $old_start		=  $h_in->{old_start};
  my $old_end		=  $h_in->{old_end};
  my $new_start		=  $h_in->{new_start};
  my $new_end		=  $h_in->{new_end};

  my $old_start_e	=  $h_in->{old_start_epoch};
  my $old_end_e		=  $h_in->{old_end_epoch};
  my $new_start_e	=  $h_in->{new_start_epoch};
  my $new_end_e		=  $h_in->{new_end_epoch};
  my $current_e		=  $h_in->{current_epoch};

  my $is_old_range_past_present = $h_in->{is_old_range_past};
  print "$fn $old_start_e<=>$old_end_e|$current_e|".
    "$new_start_e<=>$new_end_e \n";

  ##--Past: No Change
  if ($old_end_e < $current_e)
  {
    print "$fn PAST: $old_start<=>$old_end \n";
    return ($is_old_range_past_present,$errors,$old_start,$old_end);
  }
  ##-- Future: Allowed
  elsif (($old_start_e > $current_e) && ($new_start_e > $current_e) )
  {
    print "$fn Future: $new_start<=>$new_end \n";
    return ($is_old_range_past_present,$errors,$new_start,$new_end);
  }
  ##-- Present: Range is being Extended after current
  elsif ( ($old_end_e == $current_e) && ($new_end_e > $current_e))
  {
    print "$fn Present END to Forward: $old_start<=>$old_end \n";
    return ($is_old_range_past_present,$errors,$old_start,$new_end);
  }
  ##-- Present
  elsif (($old_start_e <= $current_e) && ($old_end_e >= $current_e) )
  {
    ##-- Present
    print "$fn Present: $old_start<=>$old_end \n";
    ##New END >= Today
    if ($new_end_e >= $current_e)
    {
      print "$fn Present A: $old_start<=>$new_end \n";
      return ($is_old_range_past_present,$errors,$old_start,$new_end);
    }
  }

  return ($is_old_range_past_present,$errors,$old_start,$old_end);

}

=head2 end_new_future(current_date,is_past_present,old_till,new_till)

Returns: date

=cut

sub end_new_in_future
{
  my $current_date	= shift;
  my $is_past_present	= shift;
  my $old_till		= shift;
  my $new_till		= shift;

  my $fn = "C/ztime/end_new_in_future";
  my $ending_new_in_today_future ;

   print "$fn Current:$current_date, NewEnd:$new_till \n";
  my $till_new_gt_current = 
    Class::Utils::dates_increasing($current_date,$new_till);
  if ($current_date eq $new_till)
  {
    $till_new_gt_current = 1;
  }

  if (      ($is_past_present > 0)
	 && ($current_date && $new_till)
	 && ($till_new_gt_current > 0)
	 && ($old_till ne $new_till)
	)
  {
    $ending_new_in_today_future = $new_till;
  }

  return $ending_new_in_today_future;
}

##Faster Speed
__PACKAGE__->meta->make_immutable;


=back


=end


=back

=cut

1;



=back

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
AGPLv3. Copyright tirveni@udyansh.org

=cut
