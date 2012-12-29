package Cache::Any::Manager;
use strict;
use warnings;

use Cache::Any::Proxy;
use Carp qw(croak);
use Module::Load qw(load);
use Scalar::Util qw(blessed refaddr reftype);

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
		($_ => _new_adapter(undef, $null_entry, $Cache::Any::NullAdapters{$_}))
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

	return $namespaces->{$namespace}->{'proxy'};
}

sub set {
	my $self = shift;
	my %opt;
	if(defined(reftype($_[0])) && reftype($_[0]) eq 'HASH') {
		%opt = %{shift(@_)};
	}
	my ($adapter_name, %adapter_params) = @_;

	defined($adapter_name) or croak("adapater name not specified");
	$adapter_name =~ ADAPTER_NAME_RE or croak("invalid adapter name");

	my $adapter_class = _adapter_class($adapter_name);
	load $adapter_class;

	my $pattern = _namespace_pattern($opt{'namespace'});
	my $entry = _new_entry($pattern, $adapter_class, \%adapter_params);
	$self->_add_entry($entry);

	$self->_reselect_matching_adapters();
	return $entry;
}

sub _new_adapter {
	my ($adapter, $entry, $proxy) = @_;
	defined($adapter) || defined($proxy)
		or croak("either adapter or proxy must be specified");

	$adapter ||= $proxy->{'target'};
	$proxy ||= Cache::Any::Proxy->new($adapter);

	return {
		'entry' => $entry,
		'proxy' => $proxy,
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

sub _adapter_class {
	my $class = shift;
	return $class =~ m/^\+(.*)$/
	              ? $1
	              : ADAPTER_NAMESPACE . "::$class";
}

sub _namespace_pattern {
	my $namespace = shift;
	my $pattern;
	if(defined($namespace)) {
		if(reftype($namespace) eq 'REGEXP') {
			$pattern = $namespace;
		} elsif(!defined(reftype($namespace))) {
			$pattern = qr/\Q$namespace\E$/;
		} else {
			croak("namespace must be a string or regular expression");
		}
	} else {
		$pattern = qr/.*/;
	}
	return $pattern;
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

# Substitude adapters no longer matching their namespace with more
# appropriate ones.
sub _reselect_matching_adapters {
	my ($self) = @_;
	while(my ($namespace, $ns_info) = each(%{$self->{'namespaces'}})) {
		my $entry = $self->_entry_matching_pattern($namespace);
		if(refaddr($entry) != refaddr($ns_info->{'entry'})) {
			my $adapter = $self->_adapter_for_entry($entry, $namespace);
			$ns_info->{'proxy'}->_set_target($adapter);
			$ns_info->{'adapter'} = $adapter;
			$ns_info->{'entry'} = $entry;
		}
	}
}

sub _add_entry {
	my $self = shift;
	unshift(@{$self->{'entries'}}, shift);
}

1;

