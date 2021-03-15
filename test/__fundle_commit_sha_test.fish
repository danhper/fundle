source (string join '/' (dirname (realpath (status -f))) "helper.fish")
source $current_dirname/with_repo.fish

@test "$TESTNAME: works with valid git repositories" (
	__fundle_commit_sha $repo main > /dev/null
) 0 -eq $status

@test "$TESTNAME: returns a valid sha" (
	__fundle_commit_sha $repo main | wc -m
) -eq 40
