package Cache::Any::Manager;
use strict;
use warnings;

use Carp qw(croak);
use Scalar::Util qw(blessed reftype);

use constant ADAPTER_NAMESPACE => "Cache::Any::Adapter";
use constant ADAPTER_NAME_RE => qr/\S/;
use constant NULL_ADAPTER => 'Null';

sub new {
	my $class = shift;
	my $self = {};
	bless($self, $class);

	$self->{'entries'} = [];
	$self->set(NULL_ADAPTER);

	my $null_entry = $self->{'entries'}->[0];
	$self->{'namespaces'} = {map {
		($_ => _new_adapter($Cache::Any::NullAdapters{$_}, $null_entry))
	} keys(%Cache::Any::NullAdapters)};

	return $self;
}

sub get_cache {
	my ($self, $namespace) = @_;

	my $namespaces = $self->{'namespaces'};
	if(!defined($namespaces->{$namespace})) {
		my $entry = $self->_entry_matching_pattern($namespace);
		my $adapter = $self->_adapter_for_entry($entry, $namespace);
		$namespaces->{$namespace} = _new_adapter($adapter, $entry);
	}

	return $namespaces->{$namespace}->{'adapter'};
}

sub set {
	my $self = shift;
	my %opt;
	if(reftype($_[0]) eq 'HASH') {
		%opt = %{shift(@_)};
	}
	my ($adapter_name, %adapter_params) = @_;

	defined($adapter_name) or croak("adapater name not specified");
	$adapter_name =~ ADAPTER_NAME_RE or croak("invalid adapter name");

	my $pattern;
	if(defined($opt{'namespace'})) {
		if(reftype($opt{'namespace'}) eq 'REGEXP') {
			$pattern = $opt{'namespace'};
		} elsif(!defined(reftype($opt{'namespace'}))) {
			$pattern = qr/\Q$opt{namespace}\E$/;
		} else {
			croak("namespace must be a string or regular expression");
		}
	} else {
		$pattern = qr/.*/;
	}

	my $adapter_class = $adapter_name =~ m/^\+(.*)$/
	                  ? $1
					  : ADAPTER_NAMESPACE . "::$adapter_name";
	require $adapter_class;
	my $entry = _new_entry($pattern, $adapter_class, \%adapter_params);
	unshift(@{$self->{'entries'}}, $entry);

	$self->_reselect_matching_adapters($pattern);

	return $entry;
}

sub _new_adapter {
	my ($adapter, $entry) = @_;
	return {
		'entry' => $entry,
		'adapter' => $adapter,
	};
}

sub _new_entry {
	my ($pattern, $class, $params) = @_;
	return {
		'pattern' => $pattern,
		'adapter_class' => $class,
		'adapter_params' => $params,
	};
}

sub _entry_matching_pattern {
	my ($self, $pattern) = @_;

	foreach my $entry (@{$self->{'entries'}}) {
		return $entry if $pattern =~ $entry->{'pattern'};
	}

	die("no entries matching '$pattern'");
}

sub _adapter_for_entry {
	my ($self, $entry, $namespace) = @_;
	my $class = $entry->{'adapter_class'};
	my %params = %{$entry->{'adapter_params'}};

	return $class->new(%params, 'namespace' => $namespace);
}

sub _reselect_matching_adapters {
	my ($self, $pattern) = @_;
	# FIXME $pattern is not used here. The code below is based off
	# Log::Any::Manager::_reselect_matching_adapters
	while(my ($namespace, $ns_info) = each(%{$self->{'namespace'}})) {
		my $entry = $self->_entry_matching_pattern($namespace);
		if($entry ne $ns_info->{'entry'} ) {
			my $adapter = $self->_adapter_for_entry($entry, $namespace);
			# FIXME code smell - this should not alter the internal
			# state of the adapter.
			%{$ns_info->{'adapter'}} = %$adapter;
			bless($ns_info->{'adapter'}, blessed($adapter));
			$ns_info->{'entry'} = $entry;
		}
	}
}

1;

