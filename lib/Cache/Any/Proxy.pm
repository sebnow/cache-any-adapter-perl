package Cache::Any::Proxy;
use strict;
use warnings;
use constant PROXIED_SUBS => qw(get set remove replace add exists);
use subs PROXIED_SUBS;

foreach my $sub (PROXIED_SUBS) {
	no strict 'refs';
	*{$sub} = sub {
		return shift->{'target'}->$sub(@_);
	};
}

sub new {
	my ($class, $target) = @_;
	my $self = bless({}, $class);
	$self->_set_target($target);

	return $self;
}

sub _set_target {
	my $self = shift;
	$self->{'target'} = shift;
}

1;
