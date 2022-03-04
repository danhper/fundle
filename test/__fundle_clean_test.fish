source (string join '/' (dirname (realpath (status -f))) "helper.fish")

function setup
	__fundle_common_setup
	mkdir -p $current_dirname/fundle/foo
	cp -r $current_dirname/fixtures/foo/with_init $current_dirname/fundle/foo/with_init
	cp -r $current_dirname/fixtures/foo/without_init $current_dirname/fundle/foo/without_init
	__fundle_plugin 'foo/with_init'
	__fundle_init
    set -g output (__fundle_clean)
	set -g code $status
end

function teardown --on-process-exit %self
	__fundle_clean_tmp_dir
end

setup

@test "$TESTNAME: exits with status 0" 0 -eq $code

@test "$TESTNAME: outputs info about removed plugins" 'Removing foo/without_init' = $output

@test "$TESTNAME: removes unused plugins" 'without_init' != (ls $current_dirname/fundle/foo)
