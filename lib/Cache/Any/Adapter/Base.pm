package Cache::Any::Adapter::Base;
use strict;
use warnings;

sub new {
	my $class = shift;
	my $self = {@_};
	bless($self, $class);
	$self->init(@_);
	return $self;
}

sub init {
	return;
}

sub delegate_method_to_slot {
	my ($class, $slot, $method, $adapter_method) = @_;
	*{"$class::$method"} = sub {
		my $self = shift;
		return $self->{$slot}->$adapter_method(@_);
	};
}

1;

__END__

=head1 NAME

Cache::Any::Adapter::Base - Super class of adapters

=cut

