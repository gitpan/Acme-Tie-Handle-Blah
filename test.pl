# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use Acme::Tie::Handle::Blah;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

# 2
ok( tie *FOO, 'Acme::Tie::Handle::Blah', 'zero' );
ok( print FOO "ASDF" );
ok( getc(FOO) eq "\0" );
ok( do { local $/ = "\0"; readline(*FOO) eq "\0" } );
{
    my $buffer;
    ok( read(*FOO, $buffer, 1024) == 1024 );
    ok( $buffer eq ("\0" x 1024) );
    ok( read(*FOO, $buffer, 0) == 0 );
    ok( defined $buffer and $buffer eq '' );
    ok( read(*FOO, $buffer, 123456) == 123456 );
    ok( $buffer eq ("\0" x 123456) );
}

# 12
ok( tie *FOO, 'Acme::Tie::Handle::Blah', 'null' );
ok( print FOO "ASDF" );
ok( not defined getc(FOO) );
ok( do { not defined readline(*FOO) } );
{
    my $buffer;
    ok( read(*FOO, $buffer, 1024) == 0 );
    ok( defined $buffer and $buffer eq '' );
    ok( read(*FOO, $buffer, 0) == 0 );
    ok( defined $buffer and $buffer eq '' );
    ok( read(*FOO, $buffer, 123456) == 0 );
    ok( defined $buffer and $buffer eq '' );
}

# 22
ok( tie *FOO, 'Acme::Tie::Handle::Blah', 'urandom' );
ok( print FOO "ASDF" ); # XXX - this is wrong.
ok( length(getc(FOO)) == 1 );
ok( do { local $/ = "%%"; length(readline(*FOO)) >= 2 } );
{
    my $buffer;
    ok( read(*FOO, $buffer, 1024) == 1024 );
    ok( length($buffer) == 1024 );
    ok( read(*FOO, $buffer, 0) == 0 );
    ok( defined $buffer and $buffer eq '' );
    ok( read(*FOO, $buffer, 123456) == 123456 );
    ok( length($buffer) == 123456 );
}

