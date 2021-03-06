#!/usr/bin/perl -w
#
# Copyright, Tirveni Yadav, 2015-07-19
# License: GPL v3
#

package Class::Rock;


use Readonly;
use namespace::autoclean;


=pod

=head1 NAME

Class::Rock - Constant Variables

=head1 SYNOPSIS

    use Class::Rock;
    my $c_abc  = $Class::Rock::abc;

=cut

=head2

=cut

Readonly	$maximum_rows			=> '15';
Readonly	$default_rows			=> '10';


=head2 Time in Seconds

=cut


Readonly	$seconds_day			=> '86400';
Readonly	$seconds_day_plus		=> '90000';

Readonly	$seconds_inhour			=> '3600';
Readonly	$seconds_inhour_plus		=> '3660';

Readonly	$seconds_inten			=> '600';
Readonly	$seconds_inten_plus		=> '660';

Readonly	$seconds_amin			=> '60';
Readonly	$seconds_amin_plus		=> '61';

=head1 REDIS KEYS

All the Keys for the Database REDIS

=head2

=cut

my $c_pod_id = Taipan->config->{podid};
my $podid   = "taipan:$c_pod_id:";

=head2 Country,City

Expires in An Hour

=cut

Readonly        $red_prefix_has_country         => "$podid:red_hash_country";
Readonly        $red_prefix_has_city            => "$podid:red_hash_city";


=head2 Currency

Expires in An Day

=cut

Readonly        $red_prefix_hash_currency       => "$podid:red_hash_currency";

=head2 Msg/Tvals

Refreshed SomeHow? as wall?

=cut

Readonly	$red_prefix_has_message		=> "$podid:red_hash_message";

##C/tvals
Readonly	$red_prefix_has_tval		=> "$podid:red_hash_tval";


=head2 User

Expires in a minute. As a Local cache for User

=cut

Readonly	$red_prefix_hash_appuser	=> "$podid:red_hash_appuser";
##

##In Class/Utils, Root/Auto
Readonly	$red_prefix_str_user_msg	=> "$podid:str_user_msg";




=head1 API KEYS

DEFUNCT: Class::Key

=cut

Readonly	$red_prefix_apikey  => "$podid:red_hash_appuserkey";


=head1 MAIL PROVIDERS

Sending E-Mails through SMTP or Elastice

=head2 Elastic

Used in Mail::Elastic

=cut

Readonly        $elastic_api_username   => 'info@example.io';
Readonly        $elastic_api_key        => 'aaaa-vv-ccc-ddd-ee';


=head2 SMTP

Used in Mail::Redmail

=cut

Readonly        $smtp_server            => 'mail.example.io';
Readonly        $smtp_port              => '25';
Readonly        $smtp_username          => 'info@example.io';
Readonly        $smtp_password          => 'pass#info132';



1;

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
AGPLv3. Copyright tirveni@udyansh.org

=cut
