source $DIRNAME/helper.fish

function -S setup
	__fundle_common_setup
	mkdir -p $DIRNAME/fundle/foo
	cp -r $DIRNAME/fixtures/foo/with_init $DIRNAME/fundle/foo/with_init
	cp -r $DIRNAME/fixtures/foo/without_init $DIRNAME/fundle/foo/without_init
	__fundle_plugin 'foo/with_init'
	__fundle_init
    set output (__fundle_clean)
	set code $status
end

function -S teardown
	__fundle_clean_tmp_dir
end

test "$TESTNAME: exits with status 0"
    0 -eq $code
end

test "$TESTNAME: outputs info about removed plugins"
    'Removing foo/without_init' = $output
end

test "$TESTNAME: removes unused plugins"
    'without_init' != (ls $DIRNAME/fundle/foo)
end
