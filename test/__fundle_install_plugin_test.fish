source $current_dirname/helper.fish
source $current_dirname/with_repo.fish

@test "$TESTNAME: fails when plugin cannot be fetched" (
	__fundle_install_plugin $plugin /bad/path > /dev/null 2>&1
) $status -eq 1

@test "$TESTNAME: succeeds when plugin can be fetched" (
	__fundle_install_plugin $plugin $repo > /dev/null 2>&1
) $status -eq 0
