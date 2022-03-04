set failure 0
for file in test/*_test.fish
    fishtape $file
    or set failure 1
end
exit $failure
