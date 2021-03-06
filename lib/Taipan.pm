package Taipan;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
# -Debug: activates the debug mode for very useful log messages
# ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
		 -Debug
		 ConfigLoader
		 Static::Simple

		 Session
		 Session::State::Cookie
		 Session::Store::Redis

		 Authentication
		 Authorization::Roles
		 Authorization::ACL

		 RunAfterRequest

		 Unicode::Encoding

	       /;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in taipan.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Taipan',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header

    ##testing
    testing => $ENV{TESTING} || 0,

    ## Set the right headers for nginx
    using_frontend_proxy => 1,

);


#ADD view to config
__PACKAGE__->config( default_view => 'HTML' );


##Session
__PACKAGE__->config
  (

   ##-- Session::Store::Redis
   'Plugin::Session' => 
   {
    expires => 3600,
    redis_server => '127.0.0.1:6379',
    #redis_debug => 0 # or 1!

    redis_reconnect     => 5,
    redis_every         => 500, 
   },

);


# Start the application
__PACKAGE__->setup();


=head1 NAME

Taipan - Catalyst based application

=head1 SYNOPSIS

    script/taipan_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Taipan::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut

1;
