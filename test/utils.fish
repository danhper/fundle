source $DIRNAME/helper.fish

function -S setup
	set remote 'https://github.com/tuvistavie/fundle.git'
	set revision "foobar"
end

test "__fundle_plugins_dir: returns a default value when fundle_plugins_dir is not set"
	"$HOME/.config/fish/fundle" = (__fundle_plugins_dir)
end

test "__fundle_plugins_dir: returns fundle_plugins_dir when set"
	"$DIRNAME/fundle" = (set -g fundle_plugins_dir $DIRNAME/fundle; and __fundle_plugins_dir)
end

test "__fundle_no_git: returns 1 when git is on the path"
	(__fundle_no_git) 1 -eq $status
end

test "__fundle_get_url: defaults to github url"
	"https://github.com/foo/with_init.git" = (__fundle_get_url 'foo/with_init')
end

test "__fundle_url_rev: defaults to master"
	'master' = (__fundle_url_rev $remote)
end

test "__fundle_url_rev: parses revision"
	$revision = (__fundle_url_rev "$remote#$revision")
end

test "__fundle_remote_url: keeps remote without revision intact"
	$remote = (__fundle_remote_url $remote)
end

test "__fundle_remote_url: strips the revision from the URL"
	$remote = (__fundle_remote_url "$remote#$revision")
end
