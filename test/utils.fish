source $DIRNAME/helper.fish

test "__fundle_plugins_dir: returns a default value when fundle_plugins_dir is not set"
	(__fundle_plugins_dir) = "$HOME/.config/fish/fundle"
end

set -g fundle_plugins_dir $DIRNAME/fundle
test "__fundle_plugins_dir: returns fundle_plugins_dir when set"
	(__fundle_plugins_dir) = "$DIRNAME/fundle"
end

test "__fundle_no_git: returns 0 when git is not on the path"
	(__fundle_no_git) = "git needs to be installed and in the path"
end

set -l plugin foo/with_init
test "__fundle_get_url: defaults to github url"
	(__fundle_get_url $plugin) = "https://github.com/$plugin.git"
end

set -l remote 'https://github.com/tuvistavie/fundle.git'
test "__fundle_url_rev: defaults to master"
	(__fundle_url_rev $remote) = 'master'
end

set -l revision "foobar"
test "__fundle_url_rev: parses revision"
	(__fundle_url_rev "$remote#$revision") = $revision
end

test "__fundle_remote_url: keeps remote without revision intact"
	(__fundle_remote_url $remote) = $remote
end

test "__fundle_remote_url: strips the revision from the URL"
	(__fundle_remote_url "$remote#$branch") = $remote
end
