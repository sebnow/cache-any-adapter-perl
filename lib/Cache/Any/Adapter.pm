package Cache::Any::Adapter;
use 5.006;
use strict;
use warnings;

use Cache::Any::Manager;

our $VERSION = v0.1.0;
our $INITIALIZED = 1;

my $Manager = Cache::Any::Manager->new();

foreach my $method (qw(get_cache set remove)) {
	no strict 'refs';
	*{__PACKAGE__ . "::$method"} = sub {
		shift; # class
		return $Manager->$method(@_);
	};
}

1;

