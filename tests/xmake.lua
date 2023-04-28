target("ijotests")
	add_files("*.c")
	add_includedirs("../ijolib/include")
	add_deps("ijolib")