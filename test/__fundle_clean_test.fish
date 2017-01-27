source $DIRNAME/helper.fish

function setup
	__fundle_common_setup
	mkdir -p $path/fundle/foo
	cp -r $path/fixtures/foo/with_init $path/fundle/foo/with_init
	cp -r $path/fixtures/foo/without_init $path/fundle/foo/without_init
	__fundle_plugin 'foo/with_init'
	__fundle_init
    set -g output (__fundle_clean)
	set -g code $status
end

function teardown
	__fundle_clean_tmp_dir
end

test "$TESTNAME: exits with status 0"
    0 -eq $code
end

test "$TESTNAME: outputs info about removed plugins"
    'Removing foo/without_init' = $output
end

test "$TESTNAME: removes unused plugins"
    'without_init' != (ls $path/fundle/foo)
end
