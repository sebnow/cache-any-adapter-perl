use 5.006;
use strict;
use warnings;
use File::Spec;
use Module::Build;

my $class = Module::Build->subclass(
	'class' => 'Module::Build::Custom',
	'code' => <<'SUBCLASS');
		sub ACTION_testauthor {
			my $self = shift;

			$self->depends_on(qw(build manifest distmeta));

			$self->test_files(qw(xt));
			$self->recursive_test_files(1);
			$self->depends_on('test');

			return;
		}
SUBCLASS

my $builder = $class->new(
	module_name => 'Cache::Any::Adapter',
	license => 'mit',
	configure_requires => {
		'File::Spec' => '',
		'Module::Build' => '',
	},
	build_requires => {
		'Cache::Any' => '',
		'Scalar::Util' => '',
		'Test::MockObject' => '',
		'Test::More' => '',
		'Test::Prereq::Build' => '',
	},
	requires => {
		'perl' => '>=5.006',
		'Cache::Any' => '',
		'Module::Load' => '',
	},
	add_to_cleanup => ['Cache-Any-Adapter-*'],
	create_readme => 1,
	recursive_test_files => 1,
	repository => 'git://github.com/sebnow/cache-any-adapter-perl.git',
);

# Add 't/lib' to lib path for tests
my $lib_dir = File::Spec->catdir($builder->base_dir, $builder->blib, 'lib');
my $arch_dir = File::Spec->catdir($builder->base_dir, $builder->blib, 'arch');
my $tlib_dir = File::Spec->catdir('t', 'lib');
$builder->tap_harness_args({'lib' => [$lib_dir, $arch_dir, $tlib_dir, @INC]});

$builder->create_build_script();

