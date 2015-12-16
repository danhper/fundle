source $DIRNAME/helper.fish
source $DIRNAME/with_repo.fish

test "$TESTNAME: fails when plugin cannot be fetched"
	(__fundle_install_plugin $plugin /bad/path > /dev/null ^&1) 1 -eq $status
end

test "$TESTNAME: succeeds when plugin can be fetched"
	(__fundle_install_plugin $plugin $repo > /dev/null ^&1) 0 -eq $status
end
