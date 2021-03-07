source (string join '/' (dirname (realpath (status -f))) "helper.fish")

function setup
	__fundle_cleanup_plugins
	__fundle_plugin 'foo/with_init' --url '/foo/bar'
    echo (__fundle_list)
end

setup

@test "$TESTNAME: returns all registered plugins" (count (__fundle_list -s)) -eq 1

@test "$TESTNAME: returns plugin name and url" (
    __fundle_list | string collect
) = (
    echo -e "foo/with_init\n\t/foo/bar" | string collect
)
