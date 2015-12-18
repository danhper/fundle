source $DIRNAME/helper.fish

function -S setup
	__fundle_cleanup_plugins
	__fundle_plugin 'foo/bar'
	__fundle_plugin 'foo/baz' '/path/to/baz'
	__fundle_plugin 'foo/url-flag' --url '/path/to/url-flag'
	__fundle_plugin 'foo/path-flag' --path 'path4'
	__fundle_plugin 'foo/url-path-flag' '/path/to/url-flag' --path 'path5'
	__fundle_plugin 'foo/url-flag-path-flag' --url '/path/to/url-flag' --path 'path6'
	__fundle_plugin 'foo/path-flag-url-flag' --path 'path7' --url '/path/to/url-flag'
end

test "$TESTNAME: adds plugins names"
	7 -eq (count $__fundle_plugin_names)
end

test "$TESTNAME: adds plugins urls"
	7 -eq (count $__fundle_plugin_urls)
end

test "$TESTNAME: adds plugins paths"
	7 -eq (count $__fundle_plugin_paths)
end

test "$TESTNAME: adds names in order"
	'foo/bar' = $__fundle_plugin_names[1] -a \
	'foo/baz' = $__fundle_plugin_names[2] -a \
	'foo/url-flag' = $__fundle_plugin_names[3] -a \
	'foo/path-flag' = $__fundle_plugin_names[4] -a \
	'foo/url-path-flag' = $__fundle_plugin_names[5] -a \
	'foo/url-flag-path-flag' = $__fundle_plugin_names[6] -a \
	'foo/path-flag-url-flag' = $__fundle_plugin_names[7]
end

test "$TESTNAME: uses default url when not given"
	(__fundle_get_url 'foo/bar') = $__fundle_plugin_urls[1] -a \
	(__fundle_get_url 'foo/path-flag') = $__fundle_plugin_urls[4]
end

test "$TESTNAME: uses given url"
	'/path/to/baz' = $__fundle_plugin_urls[2] -a \
	'/path/to/url-flag' = $__fundle_plugin_urls[5] -a \
	'/path/to/url-flag' = $__fundle_plugin_urls[6] -a \
	'/path/to/url-flag' = $__fundle_plugin_urls[7]
end

test "$TESTNAME: uses given path flag"
	'path4' = $__fundle_plugin_paths[4] -a \
	'path5' = $__fundle_plugin_paths[5] -a \
	'path6' = $__fundle_plugin_paths[6] -a \
	'path7' = $__fundle_plugin_paths[7]
end
