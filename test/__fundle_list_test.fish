source $current_dirname/helper.fish

function setup
	__fundle_cleanup_plugins
	__fundle_plugin 'foo/with_init' '/foo/bar'
end

@test "$TESTNAME: returns all registered plugins" (count (__fundle_list -s)) -eq 1

@test "$TESTNAME: returns plugin name and url" (
	echo -e "foo/with_init\n\t/foo/bar"
) = (__fundle_list)
