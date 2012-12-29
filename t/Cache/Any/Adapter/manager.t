#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 2;

use Test::MockModule;
use Test::MockObject;

my $mock_manager = Test::MockObject->new()->set_true(qw(get_cache set remove));
my $mock_manager_module = Test::MockModule->new('Cache::Any::Manager');
$mock_manager_module->mock('new', sub {
	return $mock_manager;
});

require Cache::Any::Adapter;

Cache::Any::Adapter->get_cache();
$mock_manager->called_ok('get_cache',
	'Given the Cache::Any::Adapter class, ' .
	'when get_cache is called, ' . 
	'then the adapter should call Cache::Any::Manager::get_cache');
$mock_manager->clear();


Cache::Any::Adapter->set('Null');
$mock_manager->called_ok('set',
	'Given the Cache::Any::Adapter class, ' .
	'when set is called, ' . 
	'then the adapter should call Cache::Any::Manager::set');
$mock_manager->clear();

# TODO: Test remove() as well. Test::MockObject has an actual remove
# method so something else must be used to mock it.

