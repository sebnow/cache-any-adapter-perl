package Cache::Any::Adapter::Mock;
use strict;
use warnings;

use Test::MockObject;

my $Mock_Object;

sub new {
	if(!defined($Mock_Object)) {
		$Mock_Object = Test::MockObject->new();
		$Mock_Object->set_isa(__PACKAGE__);
		$Mock_Object->set_false('get', 'replace', 'set', 'exists', 'add');
	}
	return $Mock_Object;
}

1;

