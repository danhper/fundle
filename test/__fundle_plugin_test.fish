source $DIRNAME/helper.fish

function -S setup
	__fundle_cleanup_plugins
	__fundle_plugin 'foo/bar'
	__fundle_plugin 'foo/baz' '/path/to/baz'
end

test "$TESTNAME: adds plugins names"
	2 -eq (count $__fundle_plugin_names)
end

test "$TESTNAME: adds plugins urls"
	2 -eq (count $__fundle_plugin_urls)
end

test "$TESTNAME: adds names in order"
	'foo/bar' = $__fundle_plugin_names[1]
end

test "$TESTNAME: uses default url when not given"
	(__fundle_get_url 'foo/bar') = $__fundle_plugin_urls[1]
end

test "$TESTNAME: uses given url"
	'/path/to/baz' = $__fundle_plugin_urls[2]
end
