source (string join '/' (dirname (realpath (status -f))) "helper.fish")

function setup
	__fundle_common_setup
	cp -r $current_dirname/fixtures/foo $current_dirname/fundle/foo
	__fundle_plugin 'foo/with_dependency' # this should recursively load 'foo/with_init'
	__fundle_plugin 'foo/without_init'
	__fundle_plugin 'foo/subfolder' --path 'plugin'
	set -g output (__fundle_init)
	set -g code $status
end

function teardown --on-process-exit %self
	__fundle_clean_tmp_dir
end

setup

@test "$TESTNAME: fails when no plugin registered" (
	__fundle_cleanup_plugins; and __fundle_init > /dev/null 2>&1
) 1 -eq $status

@test "$TESTNAME: does not fail when plugin not installed" 0 -eq $code

@test "$TESTNAME: outputs a warning when plugin not installed" -n (
	__fundle_plugin 'foo/i_dont_exit' > /dev/null 2>&1; __fundle_init | string collect
)

@test "$TESTNAME: does not output anything when all plugin are present" -z "$output"

@test "$TESTNAME: loads init.fish when present" -n "$i_have_init_file"

@test "$TESTNAME: does not load other .fish files when init.fish present" -z "$i_should_be_empty"

@test "$TESTNAME treats package as function folder when init.fish not present" -n (no_init)

@test "$TESTNAME adds functions directory to fish_function_path" (
	contains "$current_dirname/fundle/foo/with_init/functions" $fish_function_path; and \
	contains "$current_dirname/fundle/foo/subfolder/plugin/functions" $fish_function_path
) $status -eq 0

@test "$TESTNAME adds completions directory to fish_complete_path" (
	contains "$current_dirname/fundle/foo/with_init/completions" $fish_complete_path; and \
	contains "$current_dirname/fundle/foo/subfolder/plugin/completions" $fish_complete_path
) $status -eq 0

@test "$TESTNAME loads plugin functions" (functions -q my_plugin_function my_subfolder_plugin_function) 0 -eq $status

@test "$TESTNAME with profile outputs profiling info" (__fundle_init --profile | grep 'us' > /dev/null) 0 -eq $status
