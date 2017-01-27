source $DIRNAME/helper.fish

function setup
	__fundle_cleanup_plugins
	__fundle_plugin 'foo/bar'
	__fundle_plugin 'foo/baz' '/url/for/baz'
	__fundle_plugin 'foo/url-flag' --url '/url/for/url-flag'
	__fundle_plugin 'foo/path-flag' --path 'path4'
	__fundle_plugin 'foo/url-path-flag' '/url/for/url-path-flag' --path 'path5'
	__fundle_plugin 'foo/url-flag-path-flag' --url '/url/for/url-flag-path-flag' --path 'path6'
	__fundle_plugin 'foo/path-flag-url-flag' --path 'path7' --url '/url/for/path-flag-url-flag'
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
	'foo/bar foo/baz foo/url-flag foo/path-flag foo/url-path-flag foo/url-flag-path-flag foo/path-flag-url-flag' = "$__fundle_plugin_names"
end

test "$TESTNAME: uses default url when not given"
	(__fundle_get_url 'foo/bar'
	 __fundle_get_url 'foo/path-flag') = $__fundle_plugin_urls[1] $__fundle_plugin_urls[4]
end

test "$TESTNAME: uses given url"
	'/url/for/baz' \
	'/url/for/url-flag' \
	'/url/for/url-path-flag' \
	'/url/for/url-flag-path-flag' \
	'/url/for/path-flag-url-flag' = $__fundle_plugin_urls[2..3] $__fundle_plugin_urls[5..7]
end

test "$TESTNAME: uses given path flag"
	'foo/path-flag:path4' \
	'foo/url-path-flag:path5' \
	'foo/url-flag-path-flag:path6' \
	'foo/path-flag-url-flag:path7' = $__fundle_plugin_name_paths[4..7]
end
