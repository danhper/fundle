source (string join '/' (dirname (realpath (status -f))) "helper.fish")
if test -z "$XDG_CONFIG_HOME"
	set XDG_CONFIG_HOME $HOME/.config
end

function setup
	set -g remote 'https://github.com/tuvistavie/fundle.git'
	set -g revision "foobar"
end

setup

@test "__fundle_plugins_dir: returns a default value when fundle_plugins_dir is not set" (
	set -e fundle_plugins_dir; __fundle_plugins_dir
) = "$XDG_CONFIG_HOME/fish/fundle"

@test "__fundle_plugins_dir: returns fundle_plugins_dir when set" (
	set -g fundle_plugins_dir $current_dirname/fundle; and __fundle_plugins_dir
) = "$current_dirname/fundle"

@test "__fundle_no_git: returns 1 when git is on the path" (__fundle_no_git) 1 -eq $status

@test "__fundle_get_url: defaults to github url" "https://github.com/foo/with_init.git" = (__fundle_get_url 'foo/with_init')

@test "__fundle_url_rev: defaults to HEAD" 'HEAD' = (__fundle_url_rev $remote)

@test "__fundle_url_rev: parses revision" $revision = (__fundle_url_rev "$remote#$revision")

@test "__fundle_remote_url: keeps remote without revision intact" $remote = (__fundle_remote_url $remote)

@test "__fundle_remote_url: strips the revision from the URL" $remote = (__fundle_remote_url "$remote#$revision")

@test "__fundle_compare_versions: compares using semver" (printf "%s " "lt" "gt" "eq" "gt" "lt" "gt" "eq" "lt") = (printf "%s " \
		(__fundle_compare_versions 0.1.0 0.1.1) \
		(__fundle_compare_versions 0.1.2 0.1.1) \
		(__fundle_compare_versions 0.1.2 0.1.2) \
		(__fundle_compare_versions 0.10.0 0.2.2) \
		(__fundle_compare_versions 0.10.0 1.2.2) \
		(__fundle_compare_versions 1.0.0 1.0.0.beta0) \
		(__fundle_compare_versions 1.0.0.beta0 1.0.0.beta0) \
		(__fundle_compare_versions 1.0.0.beta0 1.0.0.beta1)
	)
