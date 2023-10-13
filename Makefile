# Run all test files
test:
	nvim --headless --noplugin -u ./build/test.lua -c "lua MiniTest.run()"

test_file:
	nvim --headless --noplugin -u ./build/test.lua -c "lua MiniTest.run_file('$(FILE)')"
