source $DIRNAME/helper.fish

function -S setup
	__fundle_common_setup
	__fundle_gitify $DIRNAME/fixtures/foo/with_dependency
	__fundle_gitify $DIRNAME/fixtures/foo/with_init
	__fundle_plugin 'foo/with_dependency' $DIRNAME/fixtures/foo/with_dependency
	set output (__fundle_install)
	set code $status
end

function -S teardown
	__fundle_clean_tmp_dir
end

test "$TESTNAME: succeeds when all plugins exist"
	(__fundle_cleanup_plugins;
		and __fundle_plugin 'foo/with_init' $DIRNAME/fixtures/foo/with_init;
		and __fundle_install > /dev/null) 0 -eq $status
end

test "$TESTNAME: succeeds when when plugins have dependencies"
	$code -eq 0
end

test "$TESTNAME: installs registered plugins"
	-d $fundle_plugins_dir/foo/with_dependency
end

test "$TESTNAME: installs registered plugins dependencies"
	-d $fundle_plugins_dir/foo/with_init
end
