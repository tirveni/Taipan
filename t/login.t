use strict;
use warnings;
    
# Load testing framework and use 'no_plan' to dynamically pick up
# all tests. Better to replace "'no_plan'" with "tests => 30" so it
# knows exactly how many tests need to be run (and will tell you if
# not), but 'no_plan' is nice for quick & dirty tests
    
use Test::More 'no_plan';
    
# Need to specify the name of your app as arg on next line
# Can also do:
#   use Test::WWW::Mechanize::Catalyst "Taipan";
    
use Test::WWW::Mechanize::Catalyst 'Taipan';

# Create two 'user agents' to simulate two different users ('test01' & 'test02')
my $ua1 = Test::WWW::Mechanize::Catalyst->new;

##CHECK base is Working Properly
$_->get_ok("/", "Check redirect of base URL") for $ua1;

##Check Login is Working
$ua1->get_ok("/login?userid=admin\@abc.com&password=eloor*123", "User 'admin\@abc.com' now logged in");

##Test Login
$_->get_ok("/home", "User at /home page") for $ua1;

##Test LogOut
$_->get_ok("/logout", "User logout") for $ua1;


