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

__END__

=head1 NAME

Cache::Any::Adapter - Adapter manager for Cache::Any

=head1 SYNOPSIS

	use Cache::Any::Adapter;
	use Cache::SomeImplementation;
	Cache::Any::Adapter->set('SomeImplementation');
	my $cache = Cache::Any::Adapter->get_cache();

=head1 DESCRIPTION

The C<Cache-Any-Adapter> distribution implements
L<Cache::Any|Cache::Any> class methods to specify where data should be
cached. It is a separate distribution so as to keep C<Cache::Any> itself as
simple and stable as possible.

You do not have to use anything in this distribution explicitly. It will
be auto-loaded when you call one of the methods below.

=head1 ADAPTERS

In order to use a caching mechanism with Cache::Any, there needs to be
an adapter class for it. Typically this is named
C<Cache::Any::Adapter::<I<something>>.

=head1 SETTING AND REMOVING ADAPTERS

=over

=item C<Cache::Any::Adapter->set([options], adapter_name, adapter_params)

Set the adapter to be used for all cache namespaces, or a particular
namespace.

The C<adapter_name> is the name of the adapter class. It is
automatically prepended with "C<Cache::Any::Adapter::>", unless it is
prefixed with "C<+>", in which case the name will be used verbatim.

	Cache::Any::Adapter->set('+My::Adapter');

The C<adapter_params> are passed to the adapter constructor. See the
documentation for individual adapter classes for more information.

	Cache::Any::Adapter->set('Cache::Cache', 'cache' => $cache);

An optional hash of C<options> may be passed as the first argument. The
following options can be specified:

	Cache::Any::Adapter->set({namespace => qr/^customer/}, ...);

=over

=item C<namespace>

A string containing the namespace for the cache, or a regex matching
multiple namespaces. Defaults to all namespaces.

=back

=back

=cut
