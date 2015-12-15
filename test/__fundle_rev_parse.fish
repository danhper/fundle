source $DIRNAME/helper.fish

function -S setup
	set repo $DIRNAME/fixtures/foo/with_init
	__fundle_gitify $repo
end

function -S teardown
	__fundle_clean_gitify $repo
end

test "$TESTNAME: works with valid git repositories"
	(__fundle_rev_parse "$repo/.git" master > /dev/null) $status -eq 0
end

test "$TESTNAME: returns a valid sha"
	(__fundle_rev_parse "$repo/.git" master | wc -m) -eq 40
end
