source $current_dirname/helper.fish
source $current_dirname/with_repo.fish

@test "$TESTNAME plugin: adds the repository to __fundle_plugin_names" (
	fundle plugin 'foo/with_init' $current_dirname/fixtures/foo/with_init;
		and echo $__fundle_plugin_names[1]
) = 'foo/with_init'

@test "$TESTNAME install: installs registered plugins" -d (
	fundle plugin 'foo/with_init' $current_dirname/fixtures/foo/with_init;
		and fundle install > /dev/null 2>&1;
		and echo $fundle_plugins_dir/foo/with_init
)

@test "$TESTNAME init: loads registered plugin" -n (
	mkdir -p $current_dirname/fundle/foo;
		and cp -r $current_dirname/fixtures/foo/without_init $current_dirname/fundle/foo/without_init;
		and fundle plugin 'foo/without_init';
		and fundle init;
		and no_init
)
