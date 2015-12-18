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
	7 -eq (count $__fundle_plugin_name_paths)
end

test "$TESTNAME: adds names in order"
	$__fundle_plugin_names[1] \
	$__fundle_plugin_names[2] \
	$__fundle_plugin_names[3] \
	$__fundle_plugin_names[4] \
	$__fundle_plugin_names[5] \
	$__fundle_plugin_names[6] \
	$__fundle_plugin_names[7] = (printf '%s\n' 'foo/bar' 'foo/baz' 'foo/url-flag' 'foo/path-flag' 'foo/url-path-flag' 'foo/url-flag-path-flag' 'foo/path-flag-url-flag')
end

test "$TESTNAME: uses default url when not given"
	(__fundle_get_url 'foo/bar'
	 __fundle_get_url 'foo/path-flag') = (printf '%s\n' $__fundle_plugin_urls[1] $__fundle_plugin_urls[4])
end

test "$TESTNAME: uses given url"
	$__fundle_plugin_urls[2] \
	$__fundle_plugin_urls[5] \
	$__fundle_plugin_urls[6] \
	$__fundle_plugin_urls[7] = (printf '%s\n' '/path/to/baz' '/path/to/url-flag' '/path/to/url-flag' '/path/to/url-flag')
end

test "$TESTNAME: uses given path flag"
	$__fundle_plugin_name_paths[4] \
	$__fundle_plugin_name_paths[5] \
	$__fundle_plugin_name_paths[6] \
	$__fundle_plugin_name_paths[7] = (printf '%s\n' 'foo/path-flag:path4' 'foo/url-path-flag:path5' 'foo/url-flag-path-flag:path6' 'foo/path-flag-url-flag:path7')
end
