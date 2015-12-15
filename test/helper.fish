source $DIRNAME/../functions/fundle.fish

function __fundle_gitify -a git_dir
	cd $git_dir
	git init > /dev/null
	git config user.name 'Daniel Perez' > /dev/null
	git config user.email 'tuvistavie@gmail.com' > /dev/null
	git add . > /dev/null
	git commit -m "Initial commit" > /dev/null
	cd $DIRNAME
end

function __fundle_clean_gitify -a git_dir
	rm -rf $git_dir/.git
end
