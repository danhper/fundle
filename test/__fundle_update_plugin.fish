source $DIRNAME/helper.fish
source $DIRNAME/with_repo.fish

test "$TESTNAME: fails when plugin is not present"
	(__fundle_update_plugin $plugin $repo > /dev/null ^&1) 0 -ne $status
end

test "$TESTNAME: succeeds when plugin is present"
	(__fundle_install_plugin $plugin $repo > /dev/null ^&1;
		and set -l git_dir $fundle_plugins_dir/$plugin/.git;
		and __fundle_update_plugin $git_dir $repo > /dev/null ^&1) 0 -eq $status
end
