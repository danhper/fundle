source $DIRNAME/helper.fish

function setup
	__fundle_cleanup_plugins
	__fundle_plugin 'foo/with_init' '/foo/bar'
end

test "$TESTNAME: returns all registered plugins"
	1 -eq (count (__fundle_list -s))
end

test "$TESTNAME: returns plugin name and url"
	(echo -e "foo/with_init\n\t/foo/bar") = (__fundle_list)
end
