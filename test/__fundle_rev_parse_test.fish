source (string join '/' (dirname (realpath (status -f))) "helper.fish")
source $current_dirname/with_repo.fish


@test "$TESTNAME: works with valid git repositories" (
	__fundle_rev_parse "$repo/.git" main > /dev/null
) $status -eq 0

@test "$TESTNAME: returns a valid sha" (
	__fundle_rev_parse "$repo/.git" main | wc -m
) -eq 40
