source $DIRNAME/helper.fish
source $DIRNAME/with_repo.fish

test "$TESTNAME: works with valid git repositories"
	(__fundle_commit_sha $repo master > /dev/null) 0 -eq $status
end

test "$TESTNAME: returns a valid sha"
	40 -eq (__fundle_commit_sha $repo master | wc -m)
end
