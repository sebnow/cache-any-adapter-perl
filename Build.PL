use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name => 'Cache::Any::Adapter',
	license => 'mit',
	configure_requires => {
		'Module::Build' => '',
	},
	build_requires => {
		'Cache::Any' => '',
		'Scalar::Util' => '',
		'Test::More' => '',
		'Test::Prereq::Build' => '',
	},
	requires => {
		'perl' => '>=5.006',
		'Cache::Any' => '',
	},
	add_to_cleanup => ['Cache-Any-Adapter-*'],
	create_readme => 1,
	recursive_test_files => 1,
	repository => 'git://github.com/sebnow/cache-any-adapter-perl.git',
);

$builder->create_build_script();

