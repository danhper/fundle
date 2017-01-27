source $DIRNAME/helper.fish
source $DIRNAME/with_repo.fish

test "$TESTNAME plugin: adds the repository to __fundle_plugin_names"
	'foo/with_init' = (fundle plugin 'foo/with_init' $path/fixtures/foo/with_init;
					   and echo $__fundle_plugin_names[1])
end

test "$TESTNAME install: installs registered plugins"
	-d (fundle plugin 'foo/with_init' $path/fixtures/foo/with_init;
		and fundle install > /dev/null 2>&1;
		and echo $fundle_plugins_dir/foo/with_init)
end

test "$TESTNAME init: loads registered plugin"
	-n (mkdir -p $path/fundle/foo;
		and cp -r $path/fixtures/foo/without_init $path/fundle/foo/without_init;
		and fundle plugin 'foo/without_init';
		and fundle init;
		and echo "$i_do_have_init_file")
end
