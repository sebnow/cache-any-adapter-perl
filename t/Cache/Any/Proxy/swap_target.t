#!/usr/bin/env perl
use strict;
use warnings;
use Cache::Any::Proxy;
use Test::MockObject;
use Test::More tests => 2;

{
	my $adapter1 = Test::MockObject->new()->set_true('get');
	my $adapter2 = Test::MockObject->new()->set_true('get');
	my $proxy = Cache::Any::Proxy->new($adapter1);
	$proxy->get();
	$adapter1->called_ok('get');
	$proxy->_set_target($adapter2);
	$proxy->get();
	$adapter2->called_ok('get');
}

