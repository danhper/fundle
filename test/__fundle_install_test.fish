source $current_dirname/helper.fish

function setup
	__fundle_common_setup
	__fundle_gitify $current_dirname/fixtures/foo/with_dependency
	__fundle_gitify $current_dirname/fixtures/foo/with_init
	__fundle_plugin 'foo/with_dependency' $current_dirname/fixtures/foo/with_dependency
	set output (__fundle_install)
	set -g code $status
end

function teardown
	__fundle_clean_tmp_dir
	__fundle_clean_gitify $current_dirname/fixtures/foo/with_dependency
	__fundle_clean_gitify $current_dirname/fixtures/foo/with_init
end

@test "$TESTNAME: succeeds when all plugins exist" (
	__fundle_cleanup_plugins;
		and __fundle_plugin 'foo/with_init' $current_dirname/fixtures/foo/with_init;
		and __fundle_install > /dev/null
) $status -eq 0

@test "$TESTNAME: succeeds when when plugins have dependencies" $code -eq 0

@test "$TESTNAME: installs registered plugins" -d $fundle_plugins_dir/foo/with_dependency

@test "$TESTNAME: installs registered plugins dependencies" -d $fundle_plugins_dir/foo/with_init
