#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;
use Cache::Any;
use Cache::Any::Adapter;

my $cache;

$cache = Cache::Any->get_cache();
# FIXME: Internals should not be tested. The behaviour of replacing
# adapters needs to be tested in some other way.
ok($cache->{'target'}->isa('Cache::Any::Adapter::Null'),
	'Given I have not set an adapter, ' .
	'when I retrieve a cache object, ' .
	'then the cache object should be a "Cache::Any::Adapter::Null"')
	or diag('The cache object isa ' . ref($cache->{'target'}));

Cache::Any::Adapter->set('Mock');
ok($cache->{'target'}->isa('Cache::Any::Adapter::Mock'),
	'Given I have not set an adapter, ' .
	'and I retrieved a cache object, ' .
	'when I set the cache adapter to "Mock", ' .
	'then the cache object should be a "Cache::Any::Adapter::Mock"')
	or diag('The cache object isa ' . ref($cache->{'target'}));

my $mock_adapter = Cache::Any::Adapter::Mock->new();

$cache->get('foo');
$mock_adapter->called_ok('get',
	'Given I have set the cache adapter to "Mock", ' .
	'and I have retrieved a cache object, ' .
	'when I call "get" on the cache object, ' .
	'Then the "get" should be called on the "Mock" adapter');

