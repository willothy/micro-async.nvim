# Run all test files
test:
	nvim --headless --noplugin -u ./build/test.lua "+lua require'mini.test'.run()"

test_file:
	nvim --headless --noplugin -u ./build/test.lua "+lua require'mini.test'.run_file('$(FILE)')"
