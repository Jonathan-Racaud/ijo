target("tests")
	add_files("*.c")
	add_includedirs("../ijolib/include")
	add_deps("ijolib")