source $DIRNAME/helper.fish

test "__fundle_plugins_dir: returns a default value when fundle_plugins_dir is not set"
	"$HOME/.config/fish/fundle" = (__fundle_plugins_dir)
end

set -g fundle_plugins_dir $DIRNAME/fundle
test "__fundle_plugins_dir: returns fundle_plugins_dir when set"
	"$DIRNAME/fundle" = (__fundle_plugins_dir)
end

test "__fundle_no_git: returns 0 when git is not on the path"
	"git needs to be installed and in the path" = (__fundle_no_git)
end

set -l plugin foo/with_init
test "__fundle_get_url: defaults to github url"
	"https://github.com/$plugin.git" = (__fundle_get_url $plugin)
end

set -l remote 'https://github.com/tuvistavie/fundle.git'
test "__fundle_url_rev: defaults to master"
	'master' = (__fundle_url_rev $remote)
end

set -l revision "foobar"
test "__fundle_url_rev: parses revision"
	$revision = (__fundle_url_rev "$remote#$revision")
end

test "__fundle_remote_url: keeps remote without revision intact"
	$remote = (__fundle_remote_url $remote)
end

test "__fundle_remote_url: strips the revision from the URL"
	$remote = (__fundle_remote_url "$remote#$branch")
end
