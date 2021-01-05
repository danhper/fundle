source $current_dirname/helper.fish
source $current_dirname/with_repo.fish

@test "fails when plugin is not present" (
	__fundle_update_plugin $plugin $repo > /dev/null 2>&1
) 0 -ne $status


@test "succeeds when plugin is present" (
	__fundle_install_plugin $plugin $repo > /dev/null 2>&1;
	and set -l git_dir $fundle_plugins_dir/$plugin/.git;
	and __fundle_update_plugin $plugin $repo > /dev/null 2>&1
) 0 -eq $status
