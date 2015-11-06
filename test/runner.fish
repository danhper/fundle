cd (dirname (status -f))

function __run_tests
	set -l tests (functions -n | grep test_)
	set -l success_count 0
	set -l failures_count 0
	for t in $tests
		echo -n "test '"(echo $t | sed 's/test_//')"'"
		set -l result (eval $t)
		if test $status -eq 0
			echo " ✓"
			set success_count (math $success_count + 1)
		else
			echo " ✗"
			set failures_count (math $failures_count + 1)
			echo $result
		end
	end
	echo "$success_count successes, $failures_count failures"
	return (test $failures_count -eq 0)
end

source ../functions/fundle.fish

for test_file in (ls test_*.fish)
	source $test_file
end

__run_tests
set -l ret $status

cd -

exit $ret
