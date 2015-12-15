set dir (cd (dirname (status -f)); and pwd)

function __fundle_gitify
	cd $argv[1]
	git init > /dev/null
	git add . > /dev/null
	git commit -m "Initial commit" > /dev/null
	cd $dir
end

function __fundle_clean_gitify -a git_dir
	rm -rf $git_dir/.git
end

function test___fundle_plugins_dir
	set -e fundle_plugins_dir
	if test (__fundle_plugins_dir) != "$HOME/.config/fish/fundle"
		echo '__fundle_plugins_dir should eq $HOME/.config/fish/fundle when no arg passed'
		return 1
	end

	set -g fundle_plugins_dir $dir/fundle
	if test (__fundle_plugins_dir) != "$dir/fundle"
		echo '__fundle_plugins_dir should eq $fundle_plugins_dir when set'
		return 1
	end
end

function test___fundle_no_git
	if test (__fundle_no_git)
		echo '__fundle_no_git should return 1 when git present'
		return 1
	end
end

function test___fundle_get_url
	set -l plugin foo/with_init
	if test (__fundle_get_url $plugin) != "https://github.com/$plugin.git"
		echo '__fundle_get_url should return the github repository url'
		return 1
	end
end

function test___fundle_url_rev
	set -l remote 'https://github.com/tuvistavie/fundle.git'

	if test (__fundle_url_rev $remote) != 'master'
		echo '__fundle_url_rev should default to master'
		return 1
	end

	set -l branch "foobar"
	if test (__fundle_url_rev "$remote#$branch") != $branch
		echo '__fundle_url_rev should parse rev'
		return 1
	end
end

function test___fundle_remote_url
	set -l remote 'https://github.com/tuvistavie/fundle.git'

	if test (__fundle_remote_url $remote) != $remote
		echo '__fundle_remote_url should work with no commit-ish'
		return 1
	end

	set -l branch "foobar"
	if test (__fundle_remote_url "$remote#$branch") != $remote
		echo '__fundle_remote_url should work with a commit-ish'
		return 1
	end
end

function test___fundle_rev_parse
	set -l repo $dir/fixtures/foo/with_init

	__fundle_gitify $repo

	set -l sha (__fundle_rev_parse "$repo/.git" master)
	if test $status -ne 0
		echo '__fundle_rev_parse should work with valid git repositories'
		return 1
	end
	set -l sha_length (echo -n $sha | wc -m)
	if test sha_length -ne 40
		echo '__fundle_rev_parse should return a valid sha'
		return 1
	end

	__fundle_clean_gitify $repo
end

function test___fundle_commit_sha
	set -l repo $dir/fixtures/foo/with_init

	__fundle_gitify $repo

	set -l sha (__fundle_commit_sha $repo master)
	if test $status -ne 0
		echo '__fundle_commit_sha should work with valid git repositories'
		return 1
	end
	set -l sha_length (echo -n $sha | wc -m)
	if test sha_length -ne 40
		echo '__fundle_commit_sha should return a valid sha'
		return 1
	end

	__fundle_clean_gitify $repo
end

function test___fundle_install_plugin
	set -g fundle_plugins_dir $dir/fundle
	set -l plugin foo/with_init
	set -l repo $dir/fixtures/foo/with_init
	__fundle_gitify $dir/fixtures/foo/with_init

	set -l res (__fundle_install_plugin $plugin /bad/path > /dev/null 2>&1)
	if test $status -eq 0
		echo '__fundle_install_plugin should fail when plugin does not exist'
		return 1
	end

	set -l res (__fundle_install_plugin $plugin $repo ^&1)
	if test $status -ne 0
		echo '__fundle_install_plugin should not fail when plugin exists'
		return 1
	end

	__fundle_clean_gitify $dir/fixtures/foo/with_init
	rm -rf $dir/fundle
end

function test___fundle_update_plugin
	set -g fundle_plugins_dir $dir/fundle
	set -l plugin foo/with_init
	set -l repo foo/with_init
	__fundle_gitify $dir/fixtures/foo/with_init

	# ignore output
	set -l res (__fundle_update_plugin $plugin $repo > /dev/null 2>&1)
	if test $status -eq 0
		echo '__fundle_update_plugin should fail when plugin not present'
		return 1
	end

	set -l res (__fundle_install_plugin $plugin $repo > /dev/null 2>&1)
	set -l res (__fundle_update_plugin $plugin $repo > /dev/null 2>&1)
	if test $status -eq 0
		echo '__fundle_update_plugin should succeed when plugin is present'
		return 1
	end

	__fundle_clean_gitify $dir/fixtures/foo/with_init
	rm -rf $dir/fundle
end

function test___fundle_plugin
	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls

	__fundle_plugin 'foo/bar'
	__fundle_plugin 'foo/baz' '/path/to/baz'

	echo (count $__fundle_plugin_names)
	if test (count $__fundle_plugin_names) -ne 2
		echo '__fundle_plugin should add plugins to $__fundle_plugin_names'
		return 1
	end

	if test (count $__fundle_plugin_urls) -ne 2
		echo '__fundle_plugin should add plugins to $__fundle_plugin_urls'
		return 1
	end

	if test $__fundle_plugin_names[1] != 'foo/bar'
		echo '__fundle_plugin should add names in order'
		return 1
	end

	if test $__fundle_plugin_urls[1] != (__fundle_get_url 'foo/bar')
		echo '__fundle_plugin should add urls in order and use default url when not given'
		return 1
	end

	if test $__fundle_plugin_urls[2] != '/path/to/baz'
		echo '__fundle_plugin should use given url'
		return 1
	end
end

function test___fundle_list
	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls
	set -g fundle_plugins_dir $dir/fundle

	__fundle_plugin 'foo/with_init'
	__fundle_plugin 'foo/without_init'

	if test (count (__fundle_list -s)) -ne 2
		echo '__fundle_list should return all registered plugins'
		return 1
	end

	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls

	__fundle_plugin 'foo/with_init' '/foo/bar'

	set -l actual (__fundle_list)
	set -l expected (echo -e "foo/with_init\n\t/foo/bar")
	if test "$actual" != "$expected"
		echo '__fundle_list should return plugin name and url'
		return 1
	end
end

function test___fundle_init
	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls
	set -g fundle_plugins_dir $dir/fundle

	set -l res (__fundle_init)
	if test $status -eq 0
		echo '__fundle_init should fail when no plugin registered'
		return 1
	end

	set -l res (__fundle_init)
	__fundle_plugin 'foo/bar'
	if test $status -ne 0
		echo '__fundle_init should not fail when plugin is not installed'
		return 1
	end

	if test -z "$res"
		echo '__fundle_init should output a warning when plugin not installed'
		return 1
	end

	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls

	mkdir -p $dir/fundle
	cp -r $dir/fixtures/foo $dir/fundle/foo
	__fundle_plugin 'foo/with_dependency' # this should recursively load 'foo/with_init'
	__fundle_plugin 'foo/without_init'

	set -l res (__fundle_init)
	if test -n "$res"
		echo '__fundle_init should not output anything when all plugin are present'
		echo "Output: $res"
		return 1
	end

	if test -z "$i_have_init_file"
		echo '__fundle_init should load init.fish when present'
		return 1
	end
	if test -z "$i_do_have_init_file"
		echo '__fundle_init should load all .fish files when init.fish not present'
		return 1
	end
	if test -n "$i_should_be_empty"
		echo '__fundle_init should not load other .fish files when init.fish present'
		return 1
	end

	if not contains $dir'/fundle/foo/with_init/functions' $fish_function_path
		echo '__fundle_init should add functions directory to $fish_function_path'
		return 1
	end

	if not contains $dir'/fundle/foo/with_init/completions' $fish_complete_path
		echo '__fundle_init should add completions directory to $fish_complete_path'
		return 1
	end

	if not functions -q my_plugin_function
		echo '__fundle_init should load plugin functions'
		return 1
	end

	rm -rf $dir/fundle
end

function test___fundle_init_profile
	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls
	set -g fundle_plugins_dir $dir/fundle

	mkdir -p $dir/fundle
	cp -r $dir/fixtures/foo $dir/fundle/foo
	__fundle_plugin 'foo/with_init'
	set -l res (__fundle_init --profile)
	if echo $res | grep -v 'us'
		echo "__fundle_init --profile should output the load time in us"
		return 1
	end

	rm -rf $dir/fundle
end

function test___fundle_compare_versions
	if test (__fundle_compare_versions 0.1.0 0.1.1) != "lt"
		echo '__fundle_compare_versions should return: 0.1.0 < 0.1.1'
		return 1
	end

	if test (__fundle_compare_versions 0.1.2 0.1.1) != "gt"
		echo '__fundle_compare_versions should return: 0.1.2 > 0.1.1'
		return 1
	end

	if test (__fundle_compare_versions 0.1.2 0.1.2) != "eq"
		echo '__fundle_compare_versions should return: 0.1.2 = 0.1.2'
		return 1
	end

	if test (__fundle_compare_versions 0.10.0 0.2.2) != "gt"
		echo '__fundle_compare_versions should return: 0.10.0 > 0.2.2'
		return 1
	end

	if test (__fundle_compare_versions 0.10.0 1.2.2) != "lt"
		echo '__fundle_compare_versions should return: 0.10.0 < 1.2.2'
		return 1
	end
end

function test___fundle_install
	set -g fundle_plugins_dir $dir/fundle
	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls

	__fundle_gitify $dir/fixtures/foo/with_dependency
	__fundle_gitify $dir/fixtures/foo/with_init

	__fundle_plugin 'foo/with_init' $dir/fixtures/foo/with_init

	set -l res (__fundle_install > /dev/null 2>&1)
	if test $status -ne 0
		echo '__fundle_install should succeed when all plugin exists'
		return 1
	end

	rm -rf $dir/fundle

	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls
	set -e __fundle_loaded_plugins

	__fundle_plugin 'foo/with_dependency' $dir/fixtures/foo/with_dependency
	set -l res (__fundle_install ^&1)
	if test $status -ne 0
		echo '__fundle_install should succeed when plugins have dependencies'
		return 1
	end
	if not test -d $fundle_plugins_dir/foo/with_dependency
		echo '__fundle_install should install registered plugins'
		return 1
	end
	if not test -d $fundle_plugins_dir/foo/with_init
		echo '__fundle_install should install registered plugins dependencies'
		return 1
	end

	__fundle_clean_gitify $dir/fixtures/foo/with_dependency
	__fundle_clean_gitify $dir/fixtures/foo/with_init

	rm -rf $dir/fundle
end

function test_fundle
	set -g fundle_plugins_dir $dir/fundle
	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls

	__fundle_gitify $dir/fixtures/foo/with_init

	fundle plugin 'foo/with_init' $dir/fixtures/foo/with_init
	if test $status -ne 0
		echo 'fundle plugin should not fail with correct arguments'
		return 1
	end
	if test $__fundle_plugin_names[1] != 'foo/with_init'
		echo 'fundle plugin should add the repository to $__fundle_plugin_names'
		return 1
	end

	set -l res (fundle install > /dev/null 2>&1)
	if test $status -ne 0
		echo 'fundle install should not fail with existing plugins'
		return 1
	end
	if not test -d $fundle_plugins_dir/foo/with_init
		echo 'fundle install should install registered plugins'
		return 1
	end

	cp -r $dir/fixtures/foo/without_init $dir/fundle/foo/without_init
	fundle plugin 'foo/without_init'
	fundle init
	if test $status -ne 0
		echo 'fundle init should not fail when plugin registered'
		return 1
	end
	if test -z "$i_do_have_init_file"
		echo 'fundle init should load plugins'
		return 1
	end

	__fundle_clean_gitify $dir/fixtures/foo/with_init
	rm -rf $dir/fundle
end
