package Acme::Tie::Handle::Blah;

use Carp;
use strict;

use v5.6; # stfu :)

our $VERSION = '-0.10';

my %devices = (
    zero    => sub { "\0" },
    null    => sub { undef },
    urandom => sub { chr rand 256 },
);

sub TIEHANDLE {
    my ($class, $device) = @_;
    croak "No such device: $device" unless exists $devices{$device};
    return bless \$device, $class;
}

sub GETC {
    my ($self) = @_;
    return $devices{$$self}->();
}

sub READ {
    my ($self, undef, $length, $offset) = @_;
    my         $buffer                  = \$_[1];
    $$buffer = '';
    my $read = 0;
    for (;;) {
	last if $read == $length;
	my $char = $devices{$$self}->();
	last if not defined $char;
	$$buffer .= $char;
	$read++;
    }
    return $read;
}

sub READLINE { 
    my ($self) = @_;
    my $buffer = '';
    for (;;) {
	my $char = $devices{$$self}->();
	if (not defined $char) {
	    last if length $buffer;
	    return undef;
	}
	$buffer .= $char;
	next unless defined $/;
	last if substr($buffer, -length $/) eq $/;
    }
    return $buffer;
}

sub WRITE   { 1 }
sub PRINT   { 1 }
sub PRINTF  { 1 }
sub CLOSE   { 1 }
sub UNTIE   { 1 }
sub DESTROY { 1 }

1;

=head1 NAME

Acme::Tie::Handle::Blah - emulates /dev/zero, /dev/null and /dev/urandom

=head1 SYNOPSIS

    tie *HANDLE, 'Acme::Tie::Handle::Blah', 'zero';
    tie *HANDLE, 'Acme::Tie::Handle::Blah', 'null';
    tie *HANDLE, 'Acme::Tie::Handle::Blah', 'urandom';

=head1 DESCRIPTION

This module tries to emulate the unix zero, null and urandom devices using tied
filehandles. This was made to kill time. I don't think there is a real use for
this :)

=head1 CAVEATS

Beware of endless loops. On B<zero>, C<readline> can only succeed if $/ eq "\0".

=head1 BUGS

You can write to a B<urandom> device. This is very wrong :)

The README file in this distribution is empty. This is not a bug, but an
example of what /dev/null outputs.

=head1 AUTHOR

Juerd <juerd@juerd.nl>

=cut

